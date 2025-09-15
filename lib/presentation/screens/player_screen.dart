import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_album_art.dart';
import '../providers/audio_player_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/song.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioPlayer = ref.read(audioPlayerProvider.notifier);

    if (audioState.currentSong == null) {
      return const Scaffold(
        body: Center(
          child: Text('No song playing'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textPrimary,
                        size: 32,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Album Art
              AnimatedAlbumArt(
                size: 300,
                albumArtPath: audioState.currentSong!.albumArtPath,
              ),

              const SizedBox(height: 32),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      audioState.currentSong!.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      audioState.currentSong!.artist,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Slider(
                      value: audioState.progress,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (value * audioState.duration.inMilliseconds).toInt(),
                        );
                        audioPlayer.seekTo(position);
                      },
                      activeColor: AppColors.accentElectric,
                      inactiveColor: AppColors.controlBackground,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(audioState.position),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatDuration(audioState.duration),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shuffle
                    IconButton(
                      onPressed: () => audioPlayer.toggleShuffle(),
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: audioState.isShuffleEnabled
                            ? AppColors.accentElectric
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Previous
                    IconButton(
                      onPressed: audioState.hasPrevious
                          ? () => audioPlayer.skipToPrevious()
                          : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: audioState.hasPrevious
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Play/Pause
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.accentElectric,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentElectric.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => audioPlayer.togglePlayPause(),
                        icon: Icon(
                          audioState.playbackState == PlaybackState.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.textPrimary,
                          size: 36,
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Next
                    IconButton(
                      onPressed: audioState.hasNext
                          ? () => audioPlayer.skipToNext()
                          : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: audioState.hasNext
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Repeat
                    IconButton(
                      onPressed: () {
                        RepeatMode nextMode;
                        switch (audioState.repeatMode) {
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
                        audioPlayer.setRepeatMode(nextMode);
                      },
                      icon: Icon(
                        audioState.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: audioState.repeatMode != RepeatMode.off
                            ? AppColors.accentElectric
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Additional Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      context,
                      Icons.favorite_border_rounded,
                      'Favorite',
                      () {},
                    ),
                    _buildControlButton(
                      context,
                      Icons.playlist_add_rounded,
                      'Add to Playlist',
                      () {},
                    ),
                    _buildControlButton(
                      context,
                      Icons.share_rounded,
                      'Share',
                      () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Queue Preview
              if (audioState.queue.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Text(
                        'Up Next',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View Queue',
                          style: TextStyle(color: AppColors.accentElectric),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    itemCount: audioState.queue.length > 5 ? 5 : audioState.queue.length,
                    itemBuilder: (context, index) {
                      final song = audioState.queue[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.controlBackground,
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 28,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
