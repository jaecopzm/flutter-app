import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/services/dynamic_theme_service.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../core/animations/advanced_animations.dart';
import '../../data/models/song.dart';
import '../providers/audio_player_provider.dart';
import '../providers/dynamic_theme_provider.dart';

/// Enhanced full-screen player with dynamic theming and advanced animations
class EnhancedPlayerScreen extends ConsumerStatefulWidget {
  const EnhancedPlayerScreen({super.key});

  @override
  ConsumerState<EnhancedPlayerScreen> createState() => _EnhancedPlayerScreenState();
}

class _EnhancedPlayerScreenState extends ConsumerState<EnhancedPlayerScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _albumArtController;
  late AnimationController _controlsController;
  late AnimationController _progressController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _albumArtAnimation;
  late Animation<double> _controlsAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isDraggingSlider = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _albumArtController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _controlsController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: AppAnimations.emphasizedCurve),
    );
    
    _albumArtAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _albumArtController, curve: AppAnimations.bouncyCurve),
    );
    
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsController, curve: AppAnimations.standardCurve),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start entrance animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _albumArtController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controlsController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _albumArtController.dispose();
    _controlsController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final dynamicTheme = ref.watch(dynamicThemeProvider);
    final palette = dynamicTheme.palette;
    
    if (audioState.currentSong == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.surface,
                  palette.surface.withValues(alpha: 0.9),
                  AppColorsV2.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with back button and options
                  _buildHeader(audioState.currentSong!),
                  
                  // Album art section
                  Expanded(
                    flex: 3,
                    child: _buildAlbumArtSection(audioState.currentSong!, palette),
                  ),
                  
                  // Song info section
                  _buildSongInfoSection(audioState.currentSong!, palette),
                  
                  // Progress section
                  _buildProgressSection(audioState, palette),
                  
                  // Controls section
                  _buildControlsSection(audioState, palette),
                  
                  // Bottom actions
                  _buildBottomActions(audioState.currentSong!, palette),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          AdvancedAnimations.rippleButton(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Page title
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Options button
          AdvancedAnimations.rippleButton(
            onTap: () => _showSongOptions(song),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArtSection(Song song, DynamicColorPalette palette) {
    return AnimatedBuilder(
      animation: _albumArtAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _albumArtAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(32),
            child: AdvancedAnimations.albumArtHero(
              tag: 'album_art_${song.id}',
              child: _buildAlbumArt(song, palette),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(Song song, DynamicColorPalette palette) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: song.albumArtPath != null
              ? Image.file(
                  File(song.albumArtPath!),
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.primary,
                        palette.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSongInfoSection(Song song, DynamicColorPalette palette) {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            // Song title
            Text(
              song.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Artist name
            Text(
              song.artist,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Album name
            if (song.album.isNotEmpty)
              Text(
                song.album,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(audioState, DynamicColorPalette palette) {
    final position = audioState.position;
    final duration = audioState.currentSong?.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          children: [
            // Progress slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: palette.primary,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: palette.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayColor: palette.primary.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _isDraggingSlider ? _sliderValue : progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  setState(() {
                    _isDraggingSlider = true;
                    _sliderValue = value;
                  });
                },
                onChangeEnd: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  ref.read(audioPlayerProvider.notifier).seekTo(newPosition);
                  setState(() {
                    _isDraggingSlider = false;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(audioState, DynamicColorPalette palette) {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle button
            _buildControlButton(
              icon: Icons.shuffle_rounded,
              isActive: audioState.isShuffleEnabled,
              onTap: () => ref.read(audioPlayerProvider.notifier).toggleShuffle(),
              palette: palette,
            ),
            
            // Previous button
            _buildControlButton(
              icon: Icons.skip_previous_rounded,
              size: 36,
              isEnabled: audioState.hasPrevious,
              onTap: audioState.hasPrevious
                  ? () => ref.read(audioPlayerProvider.notifier).skipToPrevious()
                  : null,
              palette: palette,
            ),
            
            // Play/Pause button (larger)
            _buildPlayPauseButton(audioState, palette),
            
            // Next button
            _buildControlButton(
              icon: Icons.skip_next_rounded,
              size: 36,
              isEnabled: audioState.hasNext,
              onTap: audioState.hasNext
                  ? () => ref.read(audioPlayerProvider.notifier).skipToNext()
                  : null,
              palette: palette,
            ),
            
            // Repeat button
            _buildControlButton(
              icon: _getRepeatIcon(audioState.repeatMode),
              isActive: audioState.repeatMode != RepeatMode.off,
              onTap: () => _toggleRepeatMode(audioState.repeatMode),
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required DynamicColorPalette palette,
    double size = 28,
    bool isActive = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return AdvancedAnimations.rippleButton(
      onTap: isEnabled && onTap != null ? onTap : () {},
      rippleColor: palette.primary,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive 
              ? palette.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: size,
          color: isEnabled
              ? (isActive ? palette.primary : Colors.white.withValues(alpha: 0.8))
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(audioState, DynamicColorPalette palette) {
    return AdvancedAnimations.rippleButton(
      onTap: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
      rippleColor: palette.primary,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.primary,
              palette.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: AppAnimations.fast,
          child: Icon(
            audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(audioState.isPlaying),
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(Song song, DynamicColorPalette palette) {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Add to playlist
            _buildActionButton(
              icon: Icons.playlist_add_rounded,
              onTap: () => _addToPlaylist(song),
              palette: palette,
            ),
            
            // Favorite
            _buildActionButton(
              icon: Icons.favorite_border_rounded,
              onTap: () => _toggleFavorite(song),
              palette: palette,
            ),
            
            // Share
            _buildActionButton(
              icon: Icons.share_rounded,
              onTap: () => _shareSong(song),
              palette: palette,
            ),
            
            // Queue
            _buildActionButton(
              icon: Icons.queue_music_rounded,
              onTap: () => _showQueue(),
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required DynamicColorPalette palette,
  }) {
    return AdvancedAnimations.rippleButton(
      onTap: onTap,
      rippleColor: palette.primary,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColorsV2.backgroundGradient,
        ),
        child: const Center(
          child: Text(
            'No song playing',
            style: TextStyle(
              color: AppColorsV2.onSurfaceVariant,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat_rounded;
      case RepeatMode.all:
        return Icons.repeat_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
    }
  }

  void _toggleRepeatMode(RepeatMode currentMode) {
    RepeatMode nextMode;
    switch (currentMode) {
      case RepeatMode.off:
        nextMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        nextMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        nextMode = RepeatMode.off;
        break;
    }
    ref.read(audioPlayerProvider.notifier).setRepeatMode(nextMode);
  }

  // Action methods
  void _showSongOptions(Song song) {
    // TODO: Implement song options bottom sheet
  }

  void _addToPlaylist(Song song) {
    // TODO: Implement add to playlist
  }

  void _toggleFavorite(Song song) {
    // TODO: Implement favorite toggle
  }

  void _shareSong(Song song) {
    // TODO: Implement song sharing
  }

  void _showQueue() {
    // TODO: Implement queue view
  }
}