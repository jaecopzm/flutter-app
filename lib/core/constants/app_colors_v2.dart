import 'package:flutter/material.dart';

/// Enhanced color system inspired by YouTube Music + Spotify
class AppColorsV2 {
  // === SPOTIFY-INSPIRED DARK BASE ===
  static const Color spotifyBlack = Color(0xFF121212);
  static const Color spotifyDarkGray = Color(0xFF181818);
  static const Color spotifyGray = Color(0xFF282828);
  static const Color spotifyLightGray = Color(0xFF404040);
  
  // === YOUTUBE MUSIC ACCENTS ===
  static const Color ytRed = Color(0xFFFF0000);
  static const Color ytRedDark = Color(0xFFCC0000);
  
  // === PREMIUM ACCENT COLORS ===
  static const Color electricBlue = Color(0xFF1DB954); // Spotify Green adapted
  static const Color neonPurple = Color(0xFF8B5FBF);
  static const Color warmOrange = Color(0xFFFF6B35);
  static const Color coolMint = Color(0xFF64FFDA);
  
  // === DYNAMIC THEME COLORS ===
  static const Color dynamicPrimary = Color(0xFF1DB954);
  static const Color dynamicSecondary = Color(0xFF8B5FBF);
  static const Color dynamicTertiary = Color(0xFF64FFDA);
  
  // === SURFACE COLORS (MATERIAL 3 INSPIRED) ===
  static const Color surface = spotifyBlack;
  static const Color surfaceVariant = spotifyDarkGray;
  static const Color surfaceContainerLowest = Color(0xFF0A0A0A);
  static const Color surfaceContainerLow = Color(0xFF1A1A1A);
  static const Color surfaceContainer = spotifyGray;
  static const Color surfaceContainerHigh = Color(0xFF2C2C2C);
  static const Color surfaceContainerHighest = Color(0xFF343434);
  
  // === TEXT COLORS WITH BETTER CONTRAST ===
  static const Color onSurface = Color(0xFFE3E3E3);
  static const Color onSurfaceVariant = Color(0xFFB3B3B3);
  static const Color onSurfaceSecondary = Color(0xFF999999);
  static const Color onSurfaceTertiary = Color(0xFF666666);
  
  // === GLASS EFFECTS (ENHANCED) ===
  static const Color glassLight = Color(0x0AFFFFFF);
  static const Color glassMedium = Color(0x14FFFFFF);
  static const Color glassStrong = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // === INTERACTION STATES ===
  static const Color pressed = Color(0x1AFFFFFF);
  static const Color hover = Color(0x0DFFFFFF);
  static const Color focused = Color(0x1FFFFFFF);
  static const Color selected = Color(0x14FFFFFF);
  
  // === STATUS COLORS (SPOTIFY STYLE) ===
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFE22134);
  static const Color info = Color(0xFF1E88E5);
  
  // === GRADIENT DEFINITIONS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1DB954),
      Color(0xFF1AA34A),
      Color(0xFF168B40),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181818),
      Color(0xFF121212),
      Color(0xFF0A0A0A),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x0AFFFFFF),
      Color(0x05FFFFFF),
    ],
  );
  
  // === SHADOW COLORS ===
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowStrong = Color(0x26000000);
  static const Color shadowColored = Color(0x331DB954);


  // === LEGACY ALIASES FOR BACKWARD COMPATIBILITY ===
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = onSurfaceTertiary;
  static const Color accentElectric = electricBlue;
  static const Color accentPurple = neonPurple;
  static const Color primaryLight = dynamicPrimary;
  static const Color controlBackground = surfaceContainer;
  static const Color glassBlack = glassMedium;
  static const Color glassWhite = glassLight;
  static const Color glassOverlay = glassBorder;
  static const Color shadowPrimary = shadowMedium;
  static const Color shadowAccent = shadowColored;
  static const Color cardBackground = surfaceContainer;
  static const Color onBackground = onSurface;
}

/// Gradients class for app-wide gradients
class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181818),
      Color(0xFF121212),
      Color(0xFF0A0A0A),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x0AFFFFFF),
      Color(0x05FFFFFF),
    ],
  );
}
