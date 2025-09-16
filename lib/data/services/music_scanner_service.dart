import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/constants/app_constants.dart';
import '../models/song.dart';

/// Service for scanning and extracting music files from device storage
class MusicScannerService {
  /// Request storage permission (handles Android 13+ properly)
  Future<bool> requestStoragePermission() async {
    final permission = await _getAppropriatePermission();
    final status = await permission.request();
    return status.isGranted;
  }

  /// Check if storage permission is granted (handles Android 13+ properly)
  Future<bool> hasStoragePermission() async {
    final permission = await _getAppropriatePermission();
    return await permission.isGranted;
  }

  /// Get the appropriate permission based on Android version
  Future<Permission> _getAppropriatePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Android 13+ (API 33+) uses granular permissions
      if (androidInfo.version.sdkInt >= 33) {
        return Permission.audio;
      }
    }
    // Fallback to storage permission for older Android versions and other platforms
    return Permission.storage;
  }

  /// Scan music files from device storage
  Future<List<Song>> scanMusicFiles() async {
    final hasPermission = await hasStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    final List<Song> songs = [];

    try {
      // Get common music directories
      final directories = await _getMusicDirectories();

      for (final directory in directories) {
        if (await directory.exists()) {
          final files = await _scanDirectory(directory);
          songs.addAll(files);
        }
      }

      // Remove duplicates based on file path
      final uniqueSongs = <String, Song>{};
      for (final song in songs) {
        uniqueSongs[song.filePath] = song;
      }

      return uniqueSongs.values.toList();
    } catch (e) {
      throw Exception('Failed to scan music files: $e');
    }
  }

  /// Get common music directories
  Future<List<Directory>> _getMusicDirectories() async {
    final List<Directory> directories = [];

    // Add external storage directories
    final externalDirs = await _getExternalStorageDirectories();
    directories.addAll(externalDirs);

    // Add common music folders
    final commonPaths = [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/DCIM',
    ];

    for (final path in commonPaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        directories.add(dir);
      }
    }

    return directories;
  }

  /// Get external storage directories
  Future<List<Directory>> _getExternalStorageDirectories() async {
    final List<Directory> directories = [];

    try {
      if (Platform.isAndroid) {
        // For Android, try common external storage paths
        final externalPaths = [
          '/storage/emulated/0',
          '/storage/sdcard0',
          '/storage/sdcard1',
        ];

        for (final path in externalPaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            directories.add(dir);
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use path_provider
        final documentsDir = await getApplicationDocumentsDirectory();
        directories.add(documentsDir);
      }
    } catch (e) {
      // Fallback to basic directory scanning
    }

    return directories;
  }

  /// Recursively scan directory for music files
  Future<List<Song>> _scanDirectory(Directory directory) async {
    final List<Song> songs = [];

    try {
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final song = await _processFile(entity);
          if (song != null) {
            songs.add(song);
          }
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
    }

    return songs;
  }

  /// Process a single file and extract metadata
  Future<Song?> _processFile(File file) async {
    try {
      // Check if file has supported extension
      final extension = file.path.split('.').last.toLowerCase();
      if (!AppConstants.supportedAudioExtensions.contains('.$extension')) {
        return null;
      }

      // Create song object with basic info
      final song = Song(
        title: _extractTitleFromPath(file.path),
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        filePath: file.path,
        duration: Duration.zero, // Will be updated when played
        fileSize: await file.length(),
      );

      return song;
    } catch (e) {
      // If metadata extraction fails, create basic song object
      return Song(
        title: _extractTitleFromPath(file.path),
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        filePath: file.path,
        duration: Duration.zero,
        fileSize: await file.length(),
      );
    }
  }

  /// Extract title from file path
  String _extractTitleFromPath(String path) {
    final fileName = path.split('/').last;
    final nameWithoutExtension = fileName.split('.').first;

    // Remove common prefixes like track numbers
    final cleanName = nameWithoutExtension.replaceAll(RegExp(r'^\d+\s*[-.]?\s*'), '');

    return cleanName.isNotEmpty ? cleanName : 'Unknown Track';
  }

  /// Scan for music files in a specific directory
  Future<List<Song>> scanDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception('Directory does not exist: $directoryPath');
    }

    return _scanDirectory(directory);
  }

  /// Get music files count in a directory
  Future<int> getMusicFilesCount(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return 0;
    }

    int count = 0;
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final extension = entity.path.split('.').last.toLowerCase();
        if (AppConstants.supportedAudioExtensions.contains('.$extension')) {
          count++;
        }
      }
    }

    return count;
  }
}