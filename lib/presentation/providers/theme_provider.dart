import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_v2.dart';

/// Theme mode state
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;
  final ThemeData currentTheme;

  ThemeState({
    this.themeMode = ThemeMode.dark,
    this.isDarkMode = true,
  }) : currentTheme = isDarkMode ? AppThemeV2.darkTheme : AppThemeV2.darkTheme;

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    final newIsDarkMode = isDarkMode ?? (themeMode == ThemeMode.dark);
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: newIsDarkMode,
    );
  }
}

/// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeState()) {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() {
    final savedTheme = _prefs.getString(AppConstants.storageKeyTheme);
    if (savedTheme != null) {
      final themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.dark,
      );
      state = state.copyWith(themeMode: themeMode);
    }
  }

  Future<void> _saveThemeToPrefs(ThemeMode themeMode) async {
    await _prefs.setString(AppConstants.storageKeyTheme, themeMode.toString());
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    final newThemeMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _saveThemeToPrefs(newThemeMode);
    state = state.copyWith(themeMode: newThemeMode);
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _saveThemeToPrefs(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

/// Convenience providers
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});

final currentThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).currentTheme;
});

/// Theme utilities provider
final themeUtilsProvider = Provider<ThemeUtils>((ref) {
  return ThemeUtils();
});

/// Theme utilities class
class ThemeUtils {
  /// Get appropriate text color based on theme
  Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isSecondary) {
      return isDark ? AppColorsV2.textSecondary : AppColorsV2.onSurface;
    }
    return isDark ? AppColorsV2.textPrimary : AppColorsV2.onBackground;
  }

  /// Get appropriate surface color
  Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColorsV2.cardBackground : AppColorsV2.surface;
  }

  /// Get appropriate glass effect color
  Color getGlassColor(BuildContext context, {double opacity = 0.8}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? AppColorsV2.glassBlack : AppColorsV2.glassWhite).withValues(alpha: opacity);
  }

  /// Get gradient background
  LinearGradient getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppGradients.backgroundGradient : AppGradients.cardGradient;
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get theme-aware shadow color
  Color getShadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? AppColorsV2.shadowPrimary : AppColorsV2.shadowAccent).withValues(alpha: 0.1);
  }
}