final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ChatScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'history/:sessionId',
            builder: (context, state) => ChatSessionScreen(
              sessionId: int.parse(state.params['sessionId']!),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error!,
    ),
  );
});