import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_personal_assistant/src/app.dart';
import 'package:ai_personal_assistant/src/config/env.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [AppObserver()],
      child: const AiPersonalAssistantApp(),
    ),
  );
}

/// Riverpod observer for logging state changes
class AppObserver extends ProviderObserver {
  final Logger _logger = Logger();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider.name != null) {
      _logger.fine('''
Provider: ${provider.name}
Type: ${provider.runtimeType}
State: ${newValue.runtimeType}
      ''');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (provider.name != null) {
      _logger.fine('Provider disposed: ${provider.name}');
    }
  }
}