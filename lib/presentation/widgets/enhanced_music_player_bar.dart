import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../core/animations/advanced_animations.dart';
import '../providers/audio_player_provider.dart';
import '../screens/enhanced_player_screen.dart';

/// Enhanced mini-player bar inspired by YouTube Music + Spotify
class EnhancedMusicPlayerBar extends ConsumerStatefulWidget {
  const EnhancedMusicPlayerBar({super.key});

  @override
  ConsumerState<EnhancedMusicPlayerBar> createState() => _EnhancedMusicPlayerBarState();
}

class _EnhancedMusicPlayerBarState extends ConsumerState<EnhancedMusicPlayerBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _progressController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: AppAnimations.emphasizedCurve),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _openPlayer() {
    Navigator.of(context).push(
      AdvancedAnimations.createPlayerTransition(
        child: const EnhancedPlayerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioPlayer = ref.read(audioPlayerProvider.notifier);

    // Don't show if no current song
    if (audioState.currentSong == null) {
      return const SizedBox.shrink();
    }

    // Animate in when song starts
    if (_slideController.status == AnimationStatus.dismissed) {
      _slideController.forward();
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.shadowMedium,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsV2.surfaceContainer.withValues(alpha: 0.9),
                    AppColorsV2.surfaceContainerLow.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: AppColorsV2.glassBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openPlayer,
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Progress indicator at the bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildProgressIndicator(audioState),
                      ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Album art with hero animation
                            Hero(
                              tag: 'album_art_${audioState.currentSong!.id}',
                              child: _buildAlbumArt(audioState.currentSong!),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Song info
                            Expanded(
                              child: _buildSongInfo(audioState.currentSong!),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Control buttons
                            _buildControlButtons(audioState, audioPlayer),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(song) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: song.albumArtPath != null
            ? Image.file(
                File(song.albumArtPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderArt(),
              )
            : _buildPlaceholderArt(),
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsV2.dynamicPrimary.withOpacity(0.3),
            AppColorsV2.dynamicSecondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColorsV2.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSongInfo(song) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColorsV2.onSurface,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          song.artist,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColorsV2.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControlButtons(audioState, audioPlayer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button with animation
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColorsV2.dynamicPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColorsV2.dynamicPrimary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => audioPlayer.togglePlayPause(),
              child: AnimatedSwitcher(
                duration: AppAnimations.fast,
                child: Icon(
                  audioState.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey(audioState.isPlaying),
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Next button
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColorsV2.surfaceContainerHigh.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: audioState.hasNext ? () => audioPlayer.skipToNext() : null,
              child: Icon(
                Icons.skip_next_rounded,
                color: audioState.hasNext
                    ? AppColorsV2.onSurface
                    : AppColorsV2.onSurfaceSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(audioState) {
    final position = audioState.position;
    final duration = audioState.currentSong?.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      height: 2,
      decoration: BoxDecoration(
        color: AppColorsV2.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsV2.dynamicPrimary,
                AppColorsV2.dynamicPrimary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}