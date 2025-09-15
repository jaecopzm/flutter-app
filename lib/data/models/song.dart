import 'package:uuid/uuid.dart';

/// Represents a music track with metadata
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final Duration duration;
  final int fileSize;
  final DateTime dateAdded;
  final DateTime? dateModified;
  final String? albumArtPath;
  final String? genre;
  final int? trackNumber;
  final int? year;
  final String? lyrics;
  final Map<String, dynamic>? metadata;

  Song({
    String? id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.duration,
    required this.fileSize,
    DateTime? dateAdded,
    this.dateModified,
    this.albumArtPath,
    this.genre,
    this.trackNumber,
    this.year,
    this.lyrics,
    this.metadata,
  }) :
    id = id ?? const Uuid().v4(),
    dateAdded = dateAdded ?? DateTime.now();

  /// Create a Song from JSON data
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      album: json['album'] as String? ?? 'Unknown Album',
      filePath: json['filePath'] as String,
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      fileSize: json['fileSize'] as int? ?? 0,
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'] as String)
          : null,
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
      albumArtPath: json['albumArtPath'] as String?,
      genre: json['genre'] as String?,
      trackNumber: json['trackNumber'] as int?,
      year: json['year'] as int?,
      lyrics: json['lyrics'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Song to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration.inMilliseconds,
      'fileSize': fileSize,
      'dateAdded': dateAdded.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
      'albumArtPath': albumArtPath,
      'genre': genre,
      'trackNumber': trackNumber,
      'year': year,
      'lyrics': lyrics,
      'metadata': metadata,
    };
  }

  /// Create a copy of the song with updated fields
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    Duration? duration,
    int? fileSize,
    DateTime? dateAdded,
    DateTime? dateModified,
    String? albumArtPath,
    String? genre,
    int? trackNumber,
    int? year,
    String? lyrics,
    Map<String, dynamic>? metadata,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      lyrics: lyrics ?? this.lyrics,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted duration string (MM:SS)
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get file size in human readable format
  String get formattedFileSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Check if song has album art
  bool get hasAlbumArt => albumArtPath != null && albumArtPath!.isNotEmpty;

  /// Check if song has lyrics
  bool get hasLyrics => lyrics != null && lyrics!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, album: $album, duration: $formattedDuration)';
  }
}

/// Enum for playback states
enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
  buffering,
}

/// Enum for repeat modes
enum RepeatMode {
  off,
  one,
  all,
}

/// Enum for shuffle modes
enum ShuffleMode {
  off,
  on,
}

/// Audio position information
class AudioPosition {
  final Duration current;
  final Duration total;
  final double progress;

  AudioPosition({
    required this.current,
    required this.total,
  }) : progress = total.inMilliseconds > 0
      ? current.inMilliseconds / total.inMilliseconds
      : 0.0;

  String get formattedCurrent => _formatDuration(current);
  String get formattedTotal => _formatDuration(total);
  String get formattedRemaining => _formatDuration(total - current);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}