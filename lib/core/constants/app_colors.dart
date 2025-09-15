import 'package:flutter/material.dart';

/// Premium color palette for the music player
class AppColors {
  // Primary colors - Deep navy to electric blue gradient
  static const Color primaryDark = Color(0xFF1a1a2e);
  static const Color primaryMedium = Color(0xFF16213e);
  static const Color primaryLight = Color(0xFF0f3460);

  // Accent colors - Electric purple and gold
  static const Color accentPurple = Color(0xFF7b2cbf);
  static const Color accentGold = Color(0xFFffd700);
  static const Color accentElectric = Color(0xFF00d4ff);

  // Background gradients
  static const List<Color> backgroundGradient = [
    primaryDark,
    primaryMedium,
    Color(0xFF2c3e50),
  ];

  // Glass effect colors
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassBlack = Color(0x80000000);
  static const Color glassOverlay = Color(0x40FFFFFF);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF808080);

  // Control colors
  static const Color controlActive = accentElectric;
  static const Color controlInactive = textSecondary;
  static const Color controlBackground = Color(0x20FFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);

  // Card colors
  static const Color cardBackground = Color(0x15FFFFFF);
  static const Color cardBorder = Color(0x30FFFFFF);

  // Shadow colors
  static const Color shadowPrimary = Color(0x40000000);
  static const Color shadowAccent = Color(0x407b2cbf);
}

/// Light theme colors (for future light mode support)
class AppColorsLight {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;
}