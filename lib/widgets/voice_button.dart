import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_personal_assistant/src/features/voice/stt_controller.dart';

class VoiceButton extends ConsumerWidget {
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoiceButton({
    super.key,
    this.size = 56,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sttState = ref.watch(sttControllerProvider);
    final sttController = ref.read(sttControllerProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: sttState.isListening
            ? activeColor ?? Theme.of(context).colorScheme.primary
            : inactiveColor ?? Theme.of(context).colorScheme.surfaceVariant,
        shape: BoxShape.circle,
        boxShadow: [
          if (sttState.isListening)
            BoxShadow(
              color: activeColor?.withOpacity(0.5) ?? 
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          sttState.isListening ? Icons.mic : Icons.mic_none,
          color: sttState.isListening
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: sttController.processVoiceInput,
        iconSize: size * 0.5,
      ),
    );
  }
}