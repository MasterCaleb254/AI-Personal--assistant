import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_personal_assistant/src/agents/base_agent.dart';
import 'package:ai_personal_assistant/src/agents/agent_service.dart';

class AgentSelector extends ConsumerWidget {
  final double iconSize;
  final Color? iconColor;

  const AgentSelector({
    super.key,
    this.iconSize = 24,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAgent = ref.watch(currentAgentProvider);
    final agents = ref.watch(agentListProvider);
    
    return PopupMenuButton<BaseAgent>(
      icon: Icon(Icons.person, size: iconSize, color: iconColor),
      tooltip: 'Select AI agent',
      onSelected: (agent) => ref.read(agentServiceProvider).setCurrentAgent(agent.agentId),
      itemBuilder: (context) => agents.map((agent) {
        return PopupMenuItem<BaseAgent>(
          value: agent,
          child: ListTile(
            leading: Icon(_getAgentIcon(agent), size: 20),
            title: Text(agent.displayName),
            subtitle: Text(
              agent.runtimeType.toString().replaceAll('Agent', ''),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        );
      }).toList(),
      offset: const Offset(0, 50),
    );
  }

  IconData _getAgentIcon(BaseAgent agent) {
    switch (agent.runtimeType) {
      case GptAgent:
        return Icons.cloud;
      case OnDeviceAgent:
        return Icons.devices;
      case LocalAgent:
        return Icons.terminal;
      default:
        return Icons.auto_awesome;
    }
  }
}