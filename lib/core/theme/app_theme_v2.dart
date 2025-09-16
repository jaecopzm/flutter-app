import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors_v2.dart';

/// Enhanced theme system inspired by YouTube Music + Spotify
class AppThemeV2 {
  static const String _fontFamily = 'Roboto';
  
  // === ENHANCED DARK THEME (PRIMARY) ===
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      // Primary colors
      primary: AppColorsV2.dynamicPrimary,
      onPrimary: Colors.black,
      primaryContainer: AppColorsV2.surfaceContainerHigh,
      onPrimaryContainer: AppColorsV2.onSurface,
      
      // Secondary colors
      secondary: AppColorsV2.dynamicSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColorsV2.surfaceContainer,
      onSecondaryContainer: AppColorsV2.onSurfaceVariant,
      
      // Tertiary colors
      tertiary: AppColorsV2.dynamicTertiary,
      onTertiary: Colors.black,
      tertiaryContainer: AppColorsV2.surfaceContainerLow,
      onTertiaryContainer: AppColorsV2.onSurfaceVariant,
      
      // Error colors
      error: AppColorsV2.error,
      onError: Colors.white,
      errorContainer: Color(0x40E22134),
      onErrorContainer: Color(0xFFFFB4AB),
      
      // Surface colors
      surface: AppColorsV2.surface,
      onSurface: AppColorsV2.onSurface,
      surfaceContainerHighest: AppColorsV2.surfaceVariant,
      onSurfaceVariant: AppColorsV2.onSurfaceVariant,
      
      // Outline colors
      outline: AppColorsV2.glassBorder,
      outlineVariant: AppColorsV2.glassMedium,
      
      // Other colors
      shadow: AppColorsV2.shadowMedium,
      scrim: Colors.black54,
      inverseSurface: AppColorsV2.onSurface,
      onInverseSurface: AppColorsV2.surface,
      inversePrimary: AppColorsV2.dynamicPrimary,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      
      // === APP BAR THEME ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsV2.surface,
        foregroundColor: AppColorsV2.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColorsV2.surface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: AppColorsV2.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // === CARD THEME ===
      cardTheme: CardThemeData(
        color: AppColorsV2.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      
      // === ELEVATED BUTTON THEME ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsV2.dynamicPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // === FILLED BUTTON THEME ===
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColorsV2.dynamicPrimary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      
      // === OUTLINED BUTTON THEME ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsV2.onSurface,
          side: const BorderSide(color: AppColorsV2.glassBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      
      // === TEXT BUTTON THEME ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsV2.dynamicPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      
      // === ICON BUTTON THEME ===
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColorsV2.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(8),
        ),
      ),
      
      // === BOTTOM NAVIGATION BAR THEME ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsV2.surface,
        selectedItemColor: AppColorsV2.dynamicPrimary,
        unselectedItemColor: AppColorsV2.onSurfaceSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
      ),
      
      // === SLIDER THEME ===
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColorsV2.dynamicPrimary,
        inactiveTrackColor: AppColorsV2.surfaceContainerHigh,
        thumbColor: AppColorsV2.dynamicPrimary,
        overlayColor: AppColorsV2.dynamicPrimary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      
      // === INPUT DECORATION THEME ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsV2.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColorsV2.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColorsV2.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColorsV2.dynamicPrimary, width: 2),
        ),
        hintStyle: _textTheme.bodyMedium?.copyWith(
          color: AppColorsV2.onSurfaceSecondary,
        ),
      ),
      
      // === DIVIDER THEME ===
      dividerTheme: const DividerThemeData(
        color: AppColorsV2.glassMedium,
        thickness: 1,
        space: 1,
      ),
      
      // === LIST TILE THEME ===
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColorsV2.selected,
        iconColor: AppColorsV2.onSurfaceVariant,
        textColor: AppColorsV2.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      
      // === TEXT THEME ===
      textTheme: _textTheme,
      
      // === SCAFFOLD BACKGROUND ===
      scaffoldBackgroundColor: AppColorsV2.surface,
      
      // === VISUAL DENSITY ===
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // === ENHANCED TEXT THEME ===
  static const TextTheme _textTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    
    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    
    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColorsV2.onSurfaceVariant,
      fontFamily: _fontFamily,
    ),
    
    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColorsV2.onSurfaceVariant,
      fontFamily: _fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColorsV2.onSurfaceSecondary,
      fontFamily: _fontFamily,
    ),
    
    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColorsV2.onSurface,
      fontFamily: _fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColorsV2.onSurfaceVariant,
      fontFamily: _fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: AppColorsV2.onSurfaceSecondary,
      fontFamily: _fontFamily,
    ),
  );
}

/// Animation durations and curves
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve emphasizedCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
}