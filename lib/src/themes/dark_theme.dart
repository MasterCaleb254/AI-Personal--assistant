import 'package:flutter/material.dart';
import 'theme_config.dart';

/// Predefined dark theme configuration
final darkTheme = ThemeConfig.dark().themeData.copyWith(
      // Additional dark theme customizations
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey[100],
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.grey[300],
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      dialogBackgroundColor: const Color(0xFF2D2F36),
    );