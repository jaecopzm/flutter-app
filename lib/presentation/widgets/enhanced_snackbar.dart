import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';

/// Enhanced snackbar with glassmorphism design and animations
class EnhancedSnackbar {
  
  /// Show success snackbar with green accent
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? action,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.success,
      action: action,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show error snackbar with red accent
  static void showError(
    BuildContext context, {
    required String message,
    String? action,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 5),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.error,
      action: action,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show warning snackbar with orange accent
  static void showWarning(
    BuildContext context, {
    required String message,
    String? action,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.warning,
      action: action,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show info snackbar with blue accent
  static void showInfo(
    BuildContext context, {
    required String message,
    String? action,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.info,
      action: action,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show loading snackbar with progress indicator
  static void showLoading(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 10),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.loading,
      duration: duration,
    );
  }

  /// Show custom snackbar with dynamic theming
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color accentColor,
    IconData? icon,
    String? action,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.custom,
      customColor: accentColor,
      customIcon: icon,
      action: action,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Color? customColor,
    IconData? customIcon,
    String? action,
    VoidCallback? onActionPressed,
    required Duration duration,
  }) {
    // Clear existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackbar = SnackBar(
      content: _EnhancedSnackbarContent(
        message: message,
        type: type,
        customColor: customColor,
        customIcon: customIcon,
        action: action,
        onActionPressed: onActionPressed,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}

/// Snackbar type enumeration
enum SnackbarType {
  success,
  error,
  warning,
  info,
  loading,
  custom,
}

/// Enhanced snackbar content widget
class _EnhancedSnackbarContent extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Color? customColor;
  final IconData? customIcon;
  final String? action;
  final VoidCallback? onActionPressed;

  const _EnhancedSnackbarContent({
    required this.message,
    required this.type,
    this.customColor,
    this.customIcon,
    this.action,
    this.onActionPressed,
  });

  @override
  State<_EnhancedSnackbarContent> createState() => _EnhancedSnackbarContentState();
}

class _EnhancedSnackbarContentState extends State<_EnhancedSnackbarContent>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.emphasizedCurve,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bouncyCurve,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSnackbarConfig();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsV2.surfaceContainer.withValues(alpha: 0.95),
                  AppColorsV2.surfaceContainerLow.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: config.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: config.accentColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColorsV2.shadowMedium,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon with animated background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: config.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: widget.type == SnackbarType.loading
                      ? _buildLoadingIndicator(config.accentColor)
                      : Icon(
                          config.icon,
                          color: config.accentColor,
                          size: 22,
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // Message text
                Expanded(
                  child: Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsV2.onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                
                // Action button
                if (widget.action != null && widget.onActionPressed != null) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onActionPressed,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: config.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: config.accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.action!,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: config.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.3),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  _SnackbarConfig _getSnackbarConfig() {
    switch (widget.type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          accentColor: AppColorsV2.success,
          icon: Icons.check_circle_rounded,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          accentColor: AppColorsV2.error,
          icon: Icons.error_rounded,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          accentColor: AppColorsV2.warning,
          icon: Icons.warning_rounded,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          accentColor: AppColorsV2.info,
          icon: Icons.info_rounded,
        );
      case SnackbarType.loading:
        return _SnackbarConfig(
          accentColor: AppColorsV2.dynamicPrimary,
          icon: Icons.hourglass_empty_rounded,
        );
      case SnackbarType.custom:
        return _SnackbarConfig(
          accentColor: widget.customColor ?? AppColorsV2.dynamicPrimary,
          icon: widget.customIcon ?? Icons.info_rounded,
        );
    }
  }
}

/// Snackbar configuration helper
class _SnackbarConfig {
  final Color accentColor;
  final IconData icon;

  const _SnackbarConfig({
    required this.accentColor,
    required this.icon,
  });
}

/// Extension for easy snackbar access
extension SnackbarExtension on BuildContext {
  void showSuccessSnackbar(String message, {String? action, VoidCallback? onAction}) {
    EnhancedSnackbar.showSuccess(this, message: message, action: action, onActionPressed: onAction);
  }

  void showErrorSnackbar(String message, {String? action, VoidCallback? onAction}) {
    EnhancedSnackbar.showError(this, message: message, action: action, onActionPressed: onAction);
  }

  void showWarningSnackbar(String message, {String? action, VoidCallback? onAction}) {
    EnhancedSnackbar.showWarning(this, message: message, action: action, onActionPressed: onAction);
  }

  void showInfoSnackbar(String message, {String? action, VoidCallback? onAction}) {
    EnhancedSnackbar.showInfo(this, message: message, action: action, onActionPressed: onAction);
  }

  void showLoadingSnackbar(String message) {
    EnhancedSnackbar.showLoading(this, message: message);
  }
}