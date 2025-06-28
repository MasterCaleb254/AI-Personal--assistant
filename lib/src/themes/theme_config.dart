import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized theme configuration with:
/// - Material 3 support
/// - Dynamic color theming
/// - Custom design tokens
/// - Theme extension support
class ThemeConfig {
  final ThemeMode mode;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final bool highContrast;

  const ThemeConfig({
    required this.mode,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    this.highContrast = false,
  });

  ThemeConfig copyWith({
    ThemeMode? mode,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    bool? highContrast,
  }) {
    return ThemeConfig(
      mode: mode ?? this.mode,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  /// Create ThemeData based on current configuration
  ThemeData get themeData {
    final isDark = mode == ThemeMode.dark;
    final colorScheme = _buildColorScheme(isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surfaceVariant,
        elevation: 1,
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      extensions: <ThemeExtension<dynamic>>[
        _CustomThemeExtension(
          aiBubbleColor: colorScheme.primaryContainer,
          userBubbleColor: colorScheme.tertiaryContainer,
          bubbleTextColor: colorScheme.onSurface,
          codeBackground: isDark 
              ? const Color(0xFF2D2D2D) 
              : const Color(0xFFF8F8F8),
          successColor: const Color(0xFF4CAF50),
          warningColor: const Color(0xFFFFC107),
          errorColor: colorScheme.error,
        ),
      ],
    );
  }

  ColorScheme _buildColorScheme(bool isDark) {
    if (highContrast) {
      return isDark
          ? const ColorScheme.highContrastDark(
              primary: Colors.amber,
              secondary: Colors.cyan,
              tertiary: Colors.lime,
            )
          : const ColorScheme.highContrastLight(
              primary: Colors.blue,
              secondary: Colors.purple,
              tertiary: Colors.teal,
            );
    }

    return ColorScheme.fromSeed(
      brightness: isDark ? Brightness.dark : Brightness.light,
      seedColor: primary,
      secondary: secondary,
      tertiary: tertiary,
    );
  }

  /// Default light theme configuration
  factory ThemeConfig.light() {
    return ThemeConfig(
      mode: ThemeMode.light,
      primary: const Color(0xFF6750A4), // Purple
      secondary: const Color(0xFF625B71), // Grayish purple
      tertiary: const Color(0xFF7D5260), // Rosy brown
    );
  }

  /// Default dark theme configuration
  factory ThemeConfig.dark() {
    return ThemeConfig(
      mode: ThemeMode.dark,
      primary: const Color(0xFFD0BCFF), // Light purple
      secondary: const Color(0xFFCCC2DC), // Pale purple
      tertiary: const Color(0xFFEFB8C8), // Light pink
    );
  }
}

/// Custom theme extensions for app-specific styling
class _CustomThemeExtension extends ThemeExtension<_CustomThemeExtension> {
  final Color aiBubbleColor;
  final Color userBubbleColor;
  final Color bubbleTextColor;
  final Color codeBackground;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  const _CustomThemeExtension({
    required this.aiBubbleColor,
    required this.userBubbleColor,
    required this.bubbleTextColor,
    required this.codeBackground,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  @override
  ThemeExtension<_CustomThemeExtension> copyWith({
    Color? aiBubbleColor,
    Color? userBubbleColor,
    Color? bubbleTextColor,
    Color? codeBackground,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return _CustomThemeExtension(
      aiBubbleColor: aiBubbleColor ?? this.aiBubbleColor,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      bubbleTextColor: bubbleTextColor ?? this.bubbleTextColor,
      codeBackground: codeBackground ?? this.codeBackground,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  ThemeExtension<_CustomThemeExtension> lerp(
      covariant ThemeExtension<_CustomThemeExtension>? other, double t) {
    if (other is! _CustomThemeExtension) return this;

    return _CustomThemeExtension(
      aiBubbleColor: Color.lerp(aiBubbleColor, other.aiBubbleColor, t)!,
      userBubbleColor: Color.lerp(userBubbleColor, other.userBubbleColor, t)!,
      bubbleTextColor: Color.lerp(bubbleTextColor, other.bubbleTextColor, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}

/// Riverpod provider for theme configuration
final themeConfigProvider = StateNotifierProvider<ThemeConfigNotifier, ThemeConfig>(
  (ref) => ThemeConfigNotifier(),
);

/// Notifier for theme configuration
class ThemeConfigNotifier extends StateNotifier<ThemeConfig> {
  ThemeConfigNotifier() : super(ThemeConfig.light());

  /// Toggle between light and dark mode
  void toggleTheme() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  /// Set custom color palette
  void setCustomColors(Color primary, Color secondary, Color tertiary) {
    state = state.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
    );
  }

  /// Toggle high contrast mode
  void toggleHighContrast() {
    state = state.copyWith(highContrast: !state.highContrast);
  }

  /// Reset to default theme
  void resetToDefault() {
    state = state.mode == ThemeMode.light 
        ? ThemeConfig.light() 
        : ThemeConfig.dark();
  }
}

/// Helper extension to access custom theme properties
extension CustomThemeExtension on ThemeData {
  _CustomThemeExtension get customExt => 
      extension<_CustomThemeExtension>()!;

  Color get aiBubbleColor => customExt.aiBubbleColor;
  Color get userBubbleColor => customExt.userBubbleColor;
  Color get bubbleTextColor => customExt.bubbleTextColor;
  Color get codeBackground => customExt.codeBackground;
  Color get successColor => customExt.successColor;
  Color get warningColor => customExt.warningColor;
  Color get errorColor => customExt.errorColor;
}