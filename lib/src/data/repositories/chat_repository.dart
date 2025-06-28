// chat_repository.dart
import 'package:ai_personal_assistant/src/data/drift/dao/chat_dao.dart';
import 'package:ai_personal_assistant/src/data/models/message.dart';
import 'package:ai_personal_assistant/src/data/vector_db/vector_repository.dart';
import 'package:ai_personal_assistant/src/utils/errors/db_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Business logic layer for chat operations
class ChatRepository {
  final ChatDao _chatDao;
  final VectorRepository _vectorRepo;
  final Logger _logger;

  ChatRepository({
    required ChatDao chatDao,
    required VectorRepository vectorRepo,
    Logger? logger,
  })  : _chatDao = chatDao,
        _vectorRepo = vectorRepo,
        _logger = logger ?? Logger();

  Future<int> startNewSession(String title, String agentId) async {
    try {
      return await _chatDao.createSession(title, agentId);
    } catch (e, stackTrace) {
      _logger.error('Failed to create session', error: e, stackTrace: stackTrace);
      throw DbFailure('Session creation failed');
    }
  }

  Stream<List<Message>> getMessages(int sessionId) {
    return _chatDao.watchMessages(sessionId);
  }

  Future<void> saveMessage(Message message) async {
    try {
      // Save to database
      await _chatDao.insertMessage(message);
      
      // Generate and store embedding if needed
      if (!message.isUser) {
        final embedding = await _vectorRepo.generateEmbedding(message.content);
        await _vectorRepo.storeEmbedding(message.id, embedding);
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to save message', error: e, stackTrace: stackTrace);
      throw DbFailure('Message save failed');
    }
  }

  Future<List<Message>> getRelevantContext(
    String query, {
    int maxResults = 5,
  }) async {
    try {
      final embedding = await _vectorRepo.generateEmbedding(query);
      final messageIds = await _vectorRepo.findSimilar(embedding, maxResults: maxResults);
      return _chatDao.getMessagesByIds(messageIds);
    } catch (e, stackTrace) {
      _logger.error('Context retrieval failed', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}