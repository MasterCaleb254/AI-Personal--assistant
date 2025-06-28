import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_personal_assistant/src/themes/theme_config.dart';

class ThemeSwitcher extends ConsumerWidget {
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const ThemeSwitcher({
    super.key,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeConfigProvider.select((config) => config.mode));
    final themeController = ref.read(themeConfigProvider.notifier);

    return IconButton(
      icon: Icon(
        themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
        size: iconSize,
        color: themeMode == ThemeMode.dark
            ? activeColor ?? Theme.of(context).colorScheme.primary
            : inactiveColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: themeController.toggleTheme,
      tooltip: themeMode == ThemeMode.dark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}