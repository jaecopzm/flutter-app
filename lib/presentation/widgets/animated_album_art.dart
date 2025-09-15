import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/song.dart';
import '../providers/audio_player_provider.dart';

/// Animated album art that rotates when music is playing
class AnimatedAlbumArt extends ConsumerStatefulWidget {
  final double size;
  final String? albumArtPath;
  final bool showPlaceholder;

  const AnimatedAlbumArt({
    super.key,
    this.size = 300,
    this.albumArtPath,
    this.showPlaceholder = true,
  });

  @override
  ConsumerState<AnimatedAlbumArt> createState() => _AnimatedAlbumArtState();
}

class _AnimatedAlbumArtState extends ConsumerState<AnimatedAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_rotationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final audioState = ref.watch(audioPlayerProvider);

    if (audioState.playbackState == PlaybackState.playing) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      if (_rotationController.isAnimating) {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: _buildAlbumArt(),
        );
      },
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentElectric.withValues(alpha: 0.3),
            AppColors.accentPurple.withValues(alpha: 0.3),
            AppColors.primaryLight.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentElectric.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: widget.albumArtPath != null
            ? Image.network(
                widget.albumArtPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (!widget.showPlaceholder) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.controlBackground,
            AppColors.controlBackground.withOpacity(0.5),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondary,
        size: widget.size * 0.4,
      ),
    );
  }
}

/// Pulsing album art effect for when music is playing
class PulsingAlbumArt extends ConsumerStatefulWidget {
  final double size;
  final String? albumArtPath;

  const PulsingAlbumArt({
    super.key,
    this.size = 60,
    this.albumArtPath,
  });

  @override
  ConsumerState<PulsingAlbumArt> createState() => _PulsingAlbumArtState();
}

class _PulsingAlbumArtState extends ConsumerState<PulsingAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePulseAnimation();
  }

  @override
  void didUpdateWidget(PulsingAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulseAnimation();
  }

  void _updatePulseAnimation() {
    final audioState = ref.watch(audioPlayerProvider);

    if (audioState.playbackState == PlaybackState.playing) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.controlBackground,
              image: widget.albumArtPath != null
                  ? DecorationImage(
                      image: NetworkImage(widget.albumArtPath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.albumArtPath == null
                ? Icon(
                    Icons.music_note_rounded,
                    color: AppColors.textSecondary,
                    size: widget.size * 0.4,
                  )
                : null,
          ),
        );
      },
    );
  }
}