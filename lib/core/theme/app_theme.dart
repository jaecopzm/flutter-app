import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Custom theme data for the music player
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryMedium,
      scaffoldBackgroundColor: AppColors.primaryDark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMedium,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentElectric,
        surface: AppColors.cardBackground,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassBlack,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentElectric,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.controlBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: AppColors.accentElectric,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentElectric,
        linearTrackColor: AppColors.controlBackground,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accentElectric,
        inactiveTrackColor: AppColors.controlBackground,
        thumbColor: AppColors.accentElectric,
        overlayColor: AppColors.accentElectric.withAlpha(51),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.glassBlack,
        selectedItemColor: AppColors.accentElectric,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Light theme (for future implementation)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColorsLight.primary,
      scaffoldBackgroundColor: AppColorsLight.background,
      // ... light theme implementation
    );
  }
}

/// Custom gradient backgrounds
class AppGradients {
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.backgroundGradient,
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accentPurple,
      AppColors.accentElectric,
    ],
  );

  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.cardBackground,
      AppColors.cardBackground.withOpacity(0.5),
    ],
  );
}
