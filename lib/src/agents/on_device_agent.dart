// on_device_agent.dart
import 'dart:ffi';
import 'package:ai_personal_assistant/src/utils/native/llama_bindings.dart';

/// On-device agent using Llama.cpp via Dart FFI
class OnDeviceAgent implements BaseAgent {
  final DynamicLibrary _library;
  late final LlamaBindings _bindings;

  /// Initialize with native library bindings
  OnDeviceAgent(this._library) {
    _bindings = LlamaBindings(_library);
    _initializeModel();
  }

  void _initializeModel() {
    final modelPath = _getModelPath();
    final success = _bindings.llama_init(modelPath.toNativeUtf8());
    if (success != 0) throw AgentFailure('Failed to initialize Llama model');
  }

  String _getModelPath() {
    // Implementation would resolve platform-specific model paths
    // e.g., via path_provider and asset bundling
    throw UnimplementedError('Model path resolution not implemented');
  }

  @override
  Future<AgentResponse> processInput({
    required String input,
    required List<Message> conversationHistory,
  }) async {
    final inputContext = _buildContext(conversationHistory, input);
    final nativeInput = inputContext.toNativeUtf8();
    
    try {
      final nativeOutput = _bindings.llama_generate(nativeInput);
      final output = nativeOutput.toDartString();

      return AgentResponse(
        content: output,
        sources: [],
        isComplete: true,
      );
    } catch (e, stackTrace) {
      throw AgentFailure(
        'On-device inference failed: ${e.toString()}',
        stackTrace: stackTrace,
      );
    } finally {
      malloc.free(nativeInput);
    }
  }

  String _buildContext(List<Message> history, String currentInput) {
    final buffer = StringBuffer();
    
    for (final message in history) {
      buffer.writeln('${message.isUser ? "User" : "Assistant"}: ${message.content}');
    }
    
    buffer.writeln('User: $currentInput');
    buffer.writeln('Assistant:');
    
    return buffer.toString();
  }

  @override
  String get agentId => 'llama_agent';

  @override
  String get displayName => 'Local Llama';

  @override
  bool get requiresInternet => false;
}