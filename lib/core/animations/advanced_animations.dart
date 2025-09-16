import 'package:flutter/material.dart';
import '../theme/app_theme_v2.dart';

/// Advanced animation utilities and custom transitions
class AdvancedAnimations {
  
  /// Hero animation tags
  static const String albumArtHeroTag = 'album_art_hero';
  static const String playerBarHeroTag = 'player_bar_hero';
  
  /// Shared element transition for album art
  static Widget albumArtHero({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Page transition with shared element support
  static PageRouteBuilder createPlayerTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from bottom with curve
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppAnimations.emphasizedCurve),
        ));

        // Fade transition for overlay
        final fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
          ),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Staggered list animation
  static Widget staggeredListAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + (delay * index),
      curve: AppAnimations.emphasizedCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Ripple animation for buttons
  static Widget rippleButton({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        splashColor: (rippleColor ?? Colors.white).withValues(alpha: 0.1),
        highlightColor: (rippleColor ?? Colors.white).withValues(alpha: 0.05),
        child: child,
      ),
    );
  }

  /// Morphing container animation
  static Widget morphingContainer({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: AppAnimations.standardCurve,
      child: child,
    );
  }

  /// Floating action animation
  static Widget floatingAction({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AppAnimations.bouncyCurve),
        ),
      ),
      child: child,
    );
  }

  /// Shimmer loading animation
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = true,
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (!isLoading) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor ?? Colors.grey[300]!,
                highlightColor ?? Colors.grey[100]!,
                baseColor ?? Colors.grey[300]!,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(slidePercent: value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Parallax scroll effect
  static Widget parallaxScroll({
    required Widget child,
    required ScrollController scrollController,
    double parallaxFactor = 0.5,
  }) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final offset = scrollController.hasClients 
            ? scrollController.offset * parallaxFactor 
            : 0.0;
        
        return Transform.translate(
          offset: Offset(0, -offset),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Elastic scale animation
  static Widget elasticScale({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final elasticValue = Curves.elasticOut.transform(animation.value);
        return Transform.scale(
          scale: elasticValue,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Breathing animation for now playing indicator
  static Widget breathingAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: 2.0 - value,
            child: child,
          ),
        );
      },
      onEnd: () {
        // Restart animation
      },
      child: child,
    );
  }

  /// Wave animation for audio visualizer
  static Widget waveAnimation({
    required List<double> heights,
    required Animation<double> animation,
    Color? color,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            heights: heights,
            animationValue: animation.value,
            color: color ?? Colors.white,
          ),
        );
      },
    );
  }
}

/// Custom gradient transform for shimmer effect
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Custom painter for wave animation
class _WavePainter extends CustomPainter {
  final List<double> heights;
  final double animationValue;
  final Color color;

  _WavePainter({
    required this.heights,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / heights.length;
    
    for (int i = 0; i < heights.length; i++) {
      final height = heights[i] * size.height * (0.5 + 0.5 * animationValue);
      final rect = Rect.fromLTWH(
        i * barWidth,
        size.height - height,
        barWidth * 0.8,
        height,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animation state manager
class AnimationStateManager {
  static final Map<String, AnimationController> _controllers = {};
  
  static AnimationController? getController(String key) {
    return _controllers[key];
  }
  
  static void registerController(String key, AnimationController controller) {
    _controllers[key] = controller;
  }
  
  static void disposeController(String key) {
    _controllers[key]?.dispose();
    _controllers.remove(key);
  }
  
  static void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}