import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/dynamic_theme_service.dart';
import '../../data/models/song.dart';
import 'audio_player_provider.dart';

/// Dynamic theme state
class DynamicThemeState {
  final DynamicColorPalette palette;
  final bool isLoading;
  final String? currentAlbumArt;
  final bool isEnabled;

  const DynamicThemeState({
    required this.palette,
    this.isLoading = false,
    this.currentAlbumArt,
    this.isEnabled = true,
  });

  DynamicThemeState copyWith({
    DynamicColorPalette? palette,
    bool? isLoading,
    String? currentAlbumArt,
    bool? isEnabled,
  }) {
    return DynamicThemeState(
      palette: palette ?? this.palette,
      isLoading: isLoading ?? this.isLoading,
      currentAlbumArt: currentAlbumArt ?? this.currentAlbumArt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Dynamic theme notifier
class DynamicThemeNotifier extends Notifier<DynamicThemeState> {
  @override
  DynamicThemeState build() {
    // Listen to current song changes
    ref.listen(currentSongProvider, (previous, next) {
      if (next != null && state.isEnabled) {
        _updateThemeFromSong(next);
      }
    });

    return const DynamicThemeState(
      palette: DynamicColorPalette.defaultPalette,
    );
  }

  /// Update theme based on current song's album art
  Future<void> _updateThemeFromSong(Song song) async {
    if (song.albumArtPath == null || song.albumArtPath == state.currentAlbumArt) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final palette = await DynamicThemeService.extractPaletteFromImage(
        song.albumArtPath!,
      );

      state = state.copyWith(
        palette: palette,
        currentAlbumArt: song.albumArtPath,
        isLoading: false,
      );
    } catch (e) {
      // Fallback to default palette
      state = state.copyWith(
        palette: DynamicColorPalette.defaultPalette,
        isLoading: false,
      );
    }
  }

  /// Manually update theme from album art path
  Future<void> updateThemeFromAlbumArt(String? albumArtPath) async {
    if (albumArtPath == null || !state.isEnabled) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final palette = await DynamicThemeService.extractPaletteFromImage(albumArtPath);
      
      state = state.copyWith(
        palette: palette,
        currentAlbumArt: albumArtPath,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        palette: DynamicColorPalette.defaultPalette,
        isLoading: false,
      );
    }
  }

  /// Toggle dynamic theming
  void toggleDynamicTheming() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    
    if (!state.isEnabled) {
      // Reset to default palette
      state = state.copyWith(
        palette: DynamicColorPalette.defaultPalette,
        currentAlbumArt: null,
      );
    } else {
      // Apply current song's theme
      final currentSong = ref.read(currentSongProvider);
      if (currentSong?.albumArtPath != null) {
        _updateThemeFromSong(currentSong!);
      }
    }
  }

  /// Reset to default theme
  void resetToDefault() {
    state = state.copyWith(
      palette: DynamicColorPalette.defaultPalette,
      currentAlbumArt: null,
      isLoading: false,
    );
  }

  /// Animate to new palette
  Future<void> animateToNewPalette(DynamicColorPalette newPalette) async {
    if (!state.isEnabled) return;

    const duration = Duration(milliseconds: 800);
    const steps = 20;
    final stepDuration = Duration(milliseconds: duration.inMilliseconds ~/ steps);

    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final interpolatedPalette = DynamicColorPalette.lerp(
        state.palette,
        newPalette,
        t,
      );

      state = state.copyWith(palette: interpolatedPalette);
      await Future.delayed(stepDuration);
    }
  }

  /// Get current background gradient
  LinearGradient get backgroundGradient {
    return DynamicThemeService.createBackgroundGradient(state.palette);
  }

  /// Get current primary gradient
  LinearGradient get primaryGradient {
    return DynamicThemeService.createGradientFromPalette(state.palette);
  }

  /// Get text color for background
  Color getTextColorForBackground(Color background, {bool isSecondary = false}) {
    return DynamicThemeService.getTextColor(background, isSecondary: isSecondary);
  }
}

/// Dynamic theme provider
final dynamicThemeProvider = NotifierProvider<DynamicThemeNotifier, DynamicThemeState>(() {
  return DynamicThemeNotifier();
});

/// Current palette provider (convenience)
final currentPaletteProvider = Provider<DynamicColorPalette>((ref) {
  return ref.watch(dynamicThemeProvider).palette;
});

/// Theme loading state provider (convenience)
final themeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dynamicThemeProvider).isLoading;
});

/// Dynamic theming enabled provider (convenience)
final dynamicThemingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(dynamicThemeProvider).isEnabled;
});

/// Background gradient provider (convenience)
final backgroundGradientProvider = Provider<LinearGradient>((ref) {
  final themeNotifier = ref.watch(dynamicThemeProvider.notifier);
  return themeNotifier.backgroundGradient;
});

/// Primary gradient provider (convenience)
final primaryGradientProvider = Provider<LinearGradient>((ref) {
  final themeNotifier = ref.watch(dynamicThemeProvider.notifier);
  return themeNotifier.primaryGradient;
});