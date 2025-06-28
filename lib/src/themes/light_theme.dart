import 'package:flutter/material.dart';
import 'theme_config.dart';

/// Predefined light theme configuration
final lightTheme = ThemeConfig.light().themeData.copyWith(
      // Additional light theme customizations
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: StadiumBorder(),
      ),
    );