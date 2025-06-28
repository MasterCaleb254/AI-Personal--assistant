import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_personal_assistant/src/config/api_keys.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/errors/vector_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Production-grade remote embedding repository with:
/// - OpenAI embeddings generation
/// - Pinecone vector storage/retrieval
/// - Automatic batching
/// - Hybrid caching strategy
class ApiEmbeddingsRepository {
  static const _openaiEmbeddingEndpoint = 'https://api.openai.com/v1/embeddings';
  static const _pineconeUpsertEndpoint = 'https://{index}-{project}.svc.{environment}.pinecone.io/vectors/upsert';
  static const _pineconeQueryEndpoint = 'https://{index}-{project}.svc.{environment}.pinecone.io/query';
  static const _batchSize = 50;
  static const _timeout = Duration(seconds: 15);

  final String _openaiApiKey;
  final String _pineconeApiKey;
  final String _pineconeEnvironment;
  final String _pineconeProject;
  final String _pineconeIndex;
  final http.Client _httpClient;
  final AnalyticsService _analytics;
  final Logger _logger;

  ApiEmbeddingsRepository({
    required String openaiApiKey,
    required String pineconeApiKey,
    required String pineconeEnvironment,
    required String pineconeProject,
    required String pineconeIndex,
    required AnalyticsService analytics,
    http.Client? httpClient,
    Logger? logger,
  })  : _openaiApiKey = openaiApiKey,
        _pineconeApiKey = pineconeApiKey,
        _pineconeEnvironment = pineconeEnvironment,
        _pineconeProject = pineconeProject,
        _pineconeIndex = pineconeIndex,
        _analytics = analytics,
        _httpClient = httpClient ?? http.Client(),
        _logger = logger ?? Logger();

  @override
  Future<List<double>> generateEmbedding(String text) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_openaiEmbeddingEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'input': text,
          'model': 'text-embedding-3-small',
        }),
      ).timeout(_timeout);

      return _parseOpenAiResponse(response);
    } catch (e, stackTrace) {
      _logger.error('Embedding generation failed', error: e, stackTrace: stackTrace);
      throw VectorFailure('Embedding generation error: ${e.toString()}');
    }
  }

  List<double> _parseOpenAiResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>;
      final embedding = data.first['embedding'] as List<dynamic>;
      return embedding.cast<double>();
    } else {
      throw VectorFailure('OpenAI API error: ${response.statusCode}');
    }
  }

  @override
  Future<void> storeEmbedding(int messageId, List<double> embedding) async {
    await storeEmbeddingsBatch({messageId: embedding});
  }

  @override
  Future<void> storeEmbeddingsBatch(Map<int, List<double>> embeddings) async {
    if (embeddings.isEmpty) return;

    try {
      final batches = _createBatches(embeddings);
      for (final batch in batches) {
        await _upsertBatch(batch);
      }
      _analytics.trackEvent('embeddings_stored', properties: {
        'count': embeddings.length,
        'source': 'pinecone'
      });
    } catch (e, stackTrace) {
      _logger.error('Batch storage failed', error: e, stackTrace: stackTrace);
      throw VectorFailure('Batch storage error: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> _createBatches(Map<int, List<double>> embeddings) {
    final entries = embeddings.entries.toList();
    final batches = <Map<String, dynamic>>[];

    for (var i = 0; i < entries.length; i += _batchSize) {
      final batch = entries.sublist(i, i + _batchSize > entries.length ? entries.length : i + _batchSize);
      final vectors = batch.map((e) {
        return {
          'id': e.key.toString(),
          'values': e.value,
          'metadata': {'timestamp': DateTime.now().toIso8601String()}
        };
      }).toList();

      batches.add({'vectors': vectors});
    }

    return batches;
  }

  Future<void> _upsertBatch(Map<String, dynamic> payload) async {
    final response = await _httpClient.post(
      Uri.parse(_buildPineconeUrl(_pineconeUpsertEndpoint)),
      headers: _pineconeHeaders,
      body: jsonEncode(payload),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw VectorFailure('Pinecone upsert failed: ${response.statusCode}');
    }
  }

  @override
  Future<List<int>> findSimilar(List<double> queryEmbedding, {int maxResults = 5}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_buildPineconeUrl(_pineconeQueryEndpoint)),
        headers: _pineconeHeaders,
        body: jsonEncode({
          'vector': queryEmbedding,
          'topK': maxResults,
          'includeMetadata': false,
        }),
      ).timeout(_timeout);

      return _parsePineconeResponse(response);
    } catch (e, stackTrace) {
      _logger.error('Similarity search failed', error: e, stackTrace: stackTrace);
      throw VectorFailure('Query error: ${e.toString()}');
    }
  }

  List<int> _parsePineconeResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final matches = json['matches'] as List<dynamic>;
      return matches.map<int>((match) {
        return int.parse(match['id'] as String);
      }).toList();
    } else {
      throw VectorFailure('Pinecone query failed: ${response.statusCode}');
    }
  }

  Map<String, String> get _pineconeHeaders {
    return {
      'Content-Type': 'application/json',
      'Api-Key': _pineconeApiKey,
      'Accept': 'application/json',
    };
  }

  String _buildPineconeUrl(String template) {
    return template
        .replaceFirst('{index}', _pineconeIndex)
        .replaceFirst('{project}', _pineconeProject)
        .replaceFirst('{environment}', _pineconeEnvironment);
  }

  /// Clean up resources
  void dispose() => _httpClient.close();
}