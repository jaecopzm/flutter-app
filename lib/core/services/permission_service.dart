import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_colors_v2.dart';
import '../../presentation/widgets/enhanced_snackbar.dart';

/// Service for handling Android permissions with enhanced UI feedback
class PermissionService {
  
  /// Check and request storage permission for music scanning
  static Future<PermissionResult> requestStoragePermission(BuildContext context) async {
    // Check if we're on Android
    if (!Platform.isAndroid) {
      return PermissionResult(
        granted: true,
        message: 'Permission not required on this platform',
      );
    }

    try {
      // Show loading feedback
      if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
      EnhancedSnackbar.showLoading(
        context,
        message: 'Checking storage permissions...',
      );

      // Determine which permission to request based on Android version
      Permission permission;
      if (await _isAndroid13OrHigher()) {
        permission = Permission.audio;
      } else {
        permission = Permission.storage;
      }

      // Check current permission status
      PermissionStatus status = await permission.status;
      
      // Handle different permission states
      switch (status) {
        case PermissionStatus.granted:
          if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
          EnhancedSnackbar.showSuccess(
            context,
            message: 'Storage permission granted!',
          );
          return PermissionResult(
            granted: true,
            message: 'Permission already granted',
          );

        case PermissionStatus.denied:
          return await _requestPermission(context, permission);

        case PermissionStatus.permanentlyDenied:
          return await _handlePermanentlyDenied(context);

        case PermissionStatus.restricted:
          if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
          EnhancedSnackbar.showError(
            context,
            message: 'Storage access is restricted on this device',
          );
          return PermissionResult(
            granted: false,
            message: 'Permission restricted',
          );

        default:
          return await _requestPermission(context, permission);
      }
    } catch (e) {
      if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
      EnhancedSnackbar.showError(
        context,
        message: 'Failed to check permissions: ${e.toString()}',
      );
      return PermissionResult(
        granted: false,
        message: 'Permission check failed',
        error: e.toString(),
      );
    }
  }

  /// Request specific permission with user-friendly dialog
  static Future<PermissionResult> _requestPermission(
    BuildContext context,
    Permission permission,
  ) async {
    // Show explanation dialog first
    if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
    final shouldRequest = await _showPermissionExplanationDialog(context, permission);
    
    if (!shouldRequest) {
      return PermissionResult(
        granted: false,
        message: 'Permission denied by user',
      );
    }

    // Show requesting feedback
    if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
    EnhancedSnackbar.showInfo(
      context,
      message: 'Requesting storage permission...',
    );

    // Request permission
    final status = await permission.request();

    switch (status) {
      case PermissionStatus.granted:
        if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
        EnhancedSnackbar.showSuccess(
          context,
          message: 'Storage permission granted! You can now scan for music.',
        );
        return PermissionResult(
          granted: true,
          message: 'Permission granted',
        );

      case PermissionStatus.denied:
        if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
        EnhancedSnackbar.showWarning(
          context,
          message: 'Storage permission is required to scan for music files',
          action: 'Retry',
          onActionPressed: () => requestStoragePermission(context),
        );
        return PermissionResult(
          granted: false,
          message: 'Permission denied',
        );

      case PermissionStatus.permanentlyDenied:
        return await _handlePermanentlyDenied(context);

      default:
        if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
        EnhancedSnackbar.showError(
          context,
          message: 'Unable to get storage permission',
        );
        return PermissionResult(
          granted: false,
          message: 'Permission request failed',
        );
    }
  }

  /// Handle permanently denied permission
  static Future<PermissionResult> _handlePermanentlyDenied(BuildContext context) async {
    if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
    final result = await _showOpenSettingsDialog(context);
    
    if (result) {
      await openAppSettings();
      if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
      EnhancedSnackbar.showInfo(
        context,
        message: 'Please enable storage permission in settings and restart the app',
      );
    } else {
      if (!context.mounted) return const PermissionResult(granted: false, message: 'Context not mounted');
      EnhancedSnackbar.showError(
        context,
        message: 'Storage permission is required to scan for music files',
      );
    }

    return PermissionResult(
      granted: false,
      message: 'Permission permanently denied',
    );
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionExplanationDialog(
    BuildContext context,
    Permission permission,
  ) async {
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PermissionExplanationDialog(permission: permission),
    );
    
    return result ?? false;
  }

  /// Show open settings dialog
  static Future<bool> _showOpenSettingsDialog(BuildContext context) async {
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _OpenSettingsDialog(),
    );
    
    return result ?? false;
  }

  /// Check if Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllRequiredPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      Permission permission;
      if (await _isAndroid13OrHigher()) {
        permission = Permission.audio;
      } else {
        permission = Permission.storage;
      }

      return await permission.isGranted;
    } catch (e) {
      return false;
    }
  }
}

/// Permission result data class
class PermissionResult {
  final bool granted;
  final String message;
  final String? error;

  const PermissionResult({
    required this.granted,
    required this.message,
    this.error,
  });
}

/// Permission explanation dialog
class _PermissionExplanationDialog extends StatelessWidget {
  final Permission permission;

  const _PermissionExplanationDialog({required this.permission});

  @override
  Widget build(BuildContext context) {
    final isAudio = permission == Permission.audio;
    
    return AlertDialog(
      backgroundColor: AppColorsV2.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColorsV2.dynamicPrimary, AppColorsV2.dynamicSecondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Storage Access Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColorsV2.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAudio
                ? 'This app needs access to your audio files to:'
                : 'This app needs storage permission to:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColorsV2.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            Icons.music_note_rounded,
            'Scan and play your music files',
          ),
          _buildFeatureItem(
            context,
            Icons.album_rounded,
            'Display album artwork',
          ),
          _buildFeatureItem(
            context,
            Icons.library_music_rounded,
            'Organize your music library',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorsV2.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColorsV2.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: AppColorsV2.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your privacy is protected. We only access music files.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsV2.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Not Now',
            style: TextStyle(color: AppColorsV2.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsV2.dynamicPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Allow Access'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColorsV2.dynamicPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsV2.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Open settings dialog
class _OpenSettingsDialog extends StatelessWidget {
  const _OpenSettingsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColorsV2.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColorsV2.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: AppColorsV2.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Permission Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColorsV2.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'Storage permission has been permanently denied. To scan for music files, please:\n\n'
        '1. Open app settings\n'
        '2. Go to Permissions\n'
        '3. Enable Storage/Files and media\n'
        '4. Restart the app',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColorsV2.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColorsV2.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsV2.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}