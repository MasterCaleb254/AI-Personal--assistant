// local_embeddings.dart
import 'dart:ffi';
import 'package:ai_personal_assistant/src/utils/errors/vector_failure.dart';
import 'package:ai_personal_assistant/src/utils/native/faiss_bindings.dart';

/// On-device vector storage using FAISS via Dart FFI
class FaissVectorRepository {
  final FaissBindings _bindings;
  final int _indexId;

  FaissVectorRepository(DynamicLibrary library)
      : _bindings = FaissBindings(library),
        _indexId = _initializeIndex(library);

  static int _initializeIndex(DynamicLibrary library) {
    final bindings = FaissBindings(library);
    return bindings.faiss_create_index(384); // 384-dim embeddings
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    // In production, this would use a local model like MiniLM
    // Simplified for example:
    return List.generate(384, (_) => 0.0);
  }

  @override
  Future<void> storeEmbedding(int messageId, List<double> embedding) async {
    try {
      final nativeArray = embedding.toFloatArray();
      final result = _bindings.faiss_add_vector(
        _indexId,
        nativeArray,
        messageId,
      );
      
      if (result != 0) {
        throw VectorFailure('FAISS storage failed');
      }
    } finally {
      malloc.free(nativeArray);
    }
  }

  @override
  Future<List<int>> findSimilar(List<double> queryEmbedding, {int maxResults = 5}) async {
    final nativeQuery = queryEmbedding.toFloatArray();
    final resultIds = Pointer<Int>.allocate(count: maxResults);
    
    try {
      final count = _bindings.faiss_search(
        _indexId,
        nativeQuery,
        maxResults,
        resultIds,
      );
      
      return List.generate(count, (i) => resultIds[i]);
    } finally {
      malloc.free(nativeQuery);
      malloc.free(resultIds);
    }
  }
}

// Helper extension for memory management
extension on List<double> {
  Pointer<Float> toFloatArray() {
    final ptr = malloc.allocate<Float>(sizeOf<Float>() * length);
    for (var i = 0; i < length; i++) {
      ptr[i] = this[i];
    }
    return ptr;
  }
}