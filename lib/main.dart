import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_personal_assistant/src/config/di.dart';
import 'package:ai_personal_assistant/src/config/env.dart';
import 'package:ai_personal_assistant/src/themes/theme_config.dart';
import 'package:ai_personal_assistant/src/services/app_lifecycle_service.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';

/// Main application widget with:
/// - Dependency injection setup
/// - Theme management
/// - Lifecycle monitoring
/// - Error handling
class AiPersonalAssistantApp extends ConsumerStatefulWidget {
  const AiPersonalAssistantApp({super.key});

  @override
  ConsumerState<AiPersonalAssistantApp> createState() => _AiPersonalAssistantAppState();
}

class _AiPersonalAssistantAppState extends ConsumerState<AiPersonalAssistantApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize services
    await ref.read(analyticsServiceProvider).initialize();
    ref.read(appLifecycleServiceProvider).startSession();
    
    // Load initial data
    await ref.read(agentServiceProvider).loadAgents();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle lifecycle changes
    final lifecycleService = ref.read(appLifecycleServiceProvider);
    
    switch (state) {
      case AppLifecycleState.resumed:
        lifecycleService.onResume();
        break;
      case AppLifecycleState.paused:
        lifecycleService.onPause();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        lifecycleService.onDetach();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    
    return MaterialApp.router(
      title: 'AI Personal Assistant',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeConfig.mode,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}