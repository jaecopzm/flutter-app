import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/models/song.dart';
import '../../core/constants/app_colors.dart';
import '../providers/audio_player_provider.dart';
import '../screens/player_screen.dart';

/// Bottom music player bar that shows current song and controls
class MusicPlayerBar extends ConsumerWidget {
  const MusicPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioPlayer = ref.read(audioPlayerProvider.notifier);

    // Don't show if no current song
    if (audioState.currentSong == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PlayerScreen(),
          ),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.glassBlack.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: AppColors.glassOverlay.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Album art
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.controlBackground.withValues(alpha: 0.8),
                  image: audioState.currentSong!.albumArtPath != null
                      ? DecorationImage(
                          image: FileImage(File(audioState.currentSong!.albumArtPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: audioState.currentSong!.albumArtPath == null
                    ? Icon(
                        Icons.music_note,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        size: 24,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Song info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioState.currentSong!.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audioState.currentSong!.artist,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Progress indicator
              SizedBox(
                width: 40,
                child: Text(
                  audioState.currentSong!.formattedDuration,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Play/Pause button
              IconButton(
                onPressed: () => audioPlayer.togglePlayPause(),
                icon: Icon(
                  audioState.playbackState == PlaybackState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: AppColors.accentElectric,
                  size: 28,
                ),
              ),

              // Next button
              IconButton(
                onPressed: audioState.hasNext ? () => audioPlayer.skipToNext() : null,
                icon: Icon(
                  Icons.skip_next,
                  color: audioState.hasNext
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
