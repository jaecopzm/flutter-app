import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../constants/app_colors_v2.dart';

/// Service for extracting colors from album art and creating dynamic themes
class DynamicThemeService {
  static const Duration _cacheDuration = Duration(minutes: 30);
  static final Map<String, _CachedPalette> _paletteCache = {};

  /// Extract color palette from album art
  static Future<DynamicColorPalette> extractPaletteFromImage(String imagePath) async {
    // Check cache first
    if (_paletteCache.containsKey(imagePath)) {
      final cached = _paletteCache[imagePath]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.palette;
      }
      _paletteCache.remove(imagePath);
    }

    try {
      final imageProvider = FileImage(File(imagePath));
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100), // Reduce size for performance
        maximumColorCount: 20,
      );

      final palette = _createDynamicPalette(paletteGenerator);
      
      // Cache the result
      _paletteCache[imagePath] = _CachedPalette(
        palette: palette,
        timestamp: DateTime.now(),
      );

      return palette;
    } catch (e) {
      // Return default palette on error
      return DynamicColorPalette.defaultPalette;
    }
  }

  /// Create dynamic color palette from PaletteGenerator
  static DynamicColorPalette _createDynamicPalette(PaletteGenerator generator) {
    // Get dominant colors
    final dominantColor = generator.dominantColor?.color ?? AppColorsV2.dynamicPrimary;
    final vibrantColor = generator.vibrantColor?.color ?? dominantColor;
    final darkVibrantColor = generator.darkVibrantColor?.color ?? dominantColor;
    final lightVibrantColor = generator.lightVibrantColor?.color ?? dominantColor;
    final mutedColor = generator.mutedColor?.color ?? dominantColor;

    // Create harmonious palette
    final hsl = HSLColor.fromColor(vibrantColor);
    
    return DynamicColorPalette(
      primary: _adjustColorForTheme(vibrantColor),
      secondary: _adjustColorForTheme(_shiftHue(vibrantColor, 30)),
      tertiary: _adjustColorForTheme(_shiftHue(vibrantColor, 60)),
      surface: _createSurfaceColor(dominantColor),
      onSurface: _createOnSurfaceColor(dominantColor),
      accent: lightVibrantColor,
      muted: mutedColor,
      vibrant: vibrantColor,
      darkVibrant: darkVibrantColor,
      lightVibrant: lightVibrantColor,
    );
  }

  /// Adjust color brightness for dark theme compatibility
  static Color _adjustColorForTheme(Color color) {
    final hsl = HSLColor.fromColor(color);
    
    // Ensure minimum brightness for visibility on dark backgrounds
    final adjustedLightness = hsl.lightness < 0.5 
        ? (hsl.lightness + 0.3).clamp(0.0, 1.0)
        : hsl.lightness;
    
    // Boost saturation for vibrancy
    final adjustedSaturation = (hsl.saturation * 1.2).clamp(0.0, 1.0);
    
    return hsl.withLightness(adjustedLightness)
             .withSaturation(adjustedSaturation)
             .toColor();
  }

  /// Create surface color from dominant color
  static Color _createSurfaceColor(Color dominantColor) {
    final hsl = HSLColor.fromColor(dominantColor);
    return hsl.withLightness(0.08).withSaturation(0.3).toColor();
  }

  /// Create on-surface color with proper contrast
  static Color _createOnSurfaceColor(Color surfaceColor) {
    final luminance = surfaceColor.computeLuminance();
    return luminance > 0.5 ? Colors.black.withValues(alpha: 0.87) : Colors.white.withValues(alpha: 0.87);
  }

  /// Shift hue by degrees
  static Color _shiftHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    final newHue = (hsl.hue + degrees) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Create gradient from palette
  static LinearGradient createGradientFromPalette(DynamicColorPalette palette) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette.primary.withValues(alpha: 0.8),
        palette.secondary.withValues(alpha: 0.6),
        palette.tertiary.withValues(alpha: 0.4),
      ],
    );
  }

  /// Create background gradient
  static LinearGradient createBackgroundGradient(DynamicColorPalette palette) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        palette.surface,
        AppColorsV2.surface,
        AppColorsV2.surfaceContainerLowest,
      ],
    );
  }

  /// Get text color with proper contrast
  static Color getTextColor(Color background, {bool isSecondary = false}) {
    final luminance = background.computeLuminance();
    final baseColor = luminance > 0.5 ? Colors.black : Colors.white;
    
    return isSecondary 
        ? baseColor.withValues(alpha: 0.7)
        : baseColor.withValues(alpha: 0.9);
  }

  /// Create theme data from palette
  static ThemeData createThemeFromPalette(DynamicColorPalette palette) {
    final colorScheme = ColorScheme.dark(
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.tertiary,
      surface: palette.surface,
      onSurface: palette.onSurface,
    );

    return ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }

  /// Clear cache
  static void clearCache() {
    _paletteCache.clear();
  }

  /// Get cache size
  static int getCacheSize() {
    return _paletteCache.length;
  }
}

/// Enhanced dynamic color palette with more color options
class DynamicColorPalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color onSurface;
  final Color accent;
  final Color muted;
  final Color vibrant;
  final Color darkVibrant;
  final Color lightVibrant;
  
  const DynamicColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.onSurface,
    required this.accent,
    required this.muted,
    required this.vibrant,
    required this.darkVibrant,
    required this.lightVibrant,
  });
  
  /// Create a palette from dominant album art color
  factory DynamicColorPalette.fromColor(Color dominantColor) {
    final hsl = HSLColor.fromColor(dominantColor);
    
    return DynamicColorPalette(
      primary: dominantColor,
      secondary: hsl.withLightness(0.6).withSaturation(0.8).toColor(),
      tertiary: hsl.withHue((hsl.hue + 120) % 360).withLightness(0.7).toColor(),
      surface: hsl.withLightness(0.08).withSaturation(0.4).toColor(),
      onSurface: hsl.withLightness(0.95).withSaturation(0.1).toColor(),
      accent: hsl.withLightness(0.8).toColor(),
      muted: hsl.withSaturation(0.3).withLightness(0.5).toColor(),
      vibrant: hsl.withSaturation(1.0).withLightness(0.6).toColor(),
      darkVibrant: hsl.withSaturation(0.8).withLightness(0.3).toColor(),
      lightVibrant: hsl.withSaturation(0.6).withLightness(0.8).toColor(),
    );
  }
  
  /// Default spotify-like palette
  static const DynamicColorPalette defaultPalette = DynamicColorPalette(
    primary: AppColorsV2.dynamicPrimary,
    secondary: AppColorsV2.dynamicSecondary,
    tertiary: AppColorsV2.dynamicTertiary,
    surface: AppColorsV2.surface,
    onSurface: AppColorsV2.onSurface,
    accent: AppColorsV2.coolMint,
    muted: AppColorsV2.onSurfaceVariant,
    vibrant: AppColorsV2.dynamicPrimary,
    darkVibrant: AppColorsV2.dynamicSecondary,
    lightVibrant: AppColorsV2.coolMint,
  );

  /// Create animated transition between palettes
  static DynamicColorPalette lerp(DynamicColorPalette a, DynamicColorPalette b, double t) {
    return DynamicColorPalette(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      vibrant: Color.lerp(a.vibrant, b.vibrant, t)!,
      darkVibrant: Color.lerp(a.darkVibrant, b.darkVibrant, t)!,
      lightVibrant: Color.lerp(a.lightVibrant, b.lightVibrant, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DynamicColorPalette &&
          runtimeType == other.runtimeType &&
          primary == other.primary &&
          secondary == other.secondary &&
          tertiary == other.tertiary;

  @override
  int get hashCode => primary.hashCode ^ secondary.hashCode ^ tertiary.hashCode;
}

/// Cached palette with timestamp
class _CachedPalette {
  final DynamicColorPalette palette;
  final DateTime timestamp;

  _CachedPalette({
    required this.palette,
    required this.timestamp,
  });
}