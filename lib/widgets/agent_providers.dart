final agentServiceProvider = Provider<AgentService>((ref) {
  return AgentService(
    ref.watch(chatRepositoryProvider),
    ref.watch(personaLoaderProvider),
  );
});

final currentAgentProvider = StateProvider<BaseAgent>((ref) {
  return ref.watch(agentServiceProvider).currentAgent;
});

final agentListProvider = FutureProvider<List<BaseAgent>>((ref) async {
  return ref.watch(agentServiceProvider).getAvailableAgents();
});