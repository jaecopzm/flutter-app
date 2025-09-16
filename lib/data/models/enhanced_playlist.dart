import 'dart:ui';
import 'package:uuid/uuid.dart';
import 'song.dart';

/// Enhanced playlist model with advanced features
class EnhancedPlaylist {
  final String id;
  final String name;
  final String description;
  final List<Song> songs;
  final String? coverImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isPublic;
  final bool isCollaborative;
  final List<String> collaborators;
  final Map<String, dynamic> metadata;
  final PlaylistType type;
  final Color? customColor;

  EnhancedPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.songs,
    this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isPublic = false,
    this.isCollaborative = false,
    this.collaborators = const [],
    this.metadata = const {},
    this.type = PlaylistType.user,
    this.customColor,
  });

  /// Create a new playlist
  factory EnhancedPlaylist.create({
    required String name,
    String description = '',
    String createdBy = 'user',
    bool isPublic = false,
    bool isCollaborative = false,
    PlaylistType type = PlaylistType.user,
    Color? customColor,
  }) {
    final now = DateTime.now();
    return EnhancedPlaylist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      songs: [],
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      isPublic: isPublic,
      isCollaborative: isCollaborative,
      type: type,
      customColor: customColor,
    );
  }

  /// Create a smart playlist
  factory EnhancedPlaylist.smart({
    required String name,
    required String description,
    required List<Song> songs,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    return EnhancedPlaylist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      songs: songs,
      createdAt: now,
      updatedAt: now,
      createdBy: 'system',
      type: PlaylistType.smart,
      metadata: metadata,
    );
  }

  /// Copy with method
  EnhancedPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    List<Song>? songs,
    String? coverImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isPublic,
    bool? isCollaborative,
    List<String>? collaborators,
    Map<String, dynamic>? metadata,
    PlaylistType? type,
    Color? customColor,
  }) {
    return EnhancedPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songs: songs ?? this.songs,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      collaborators: collaborators ?? this.collaborators,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
      customColor: customColor ?? this.customColor,
    );
  }

  /// Add song to playlist
  EnhancedPlaylist addSong(Song song) {
    if (songs.any((s) => s.id == song.id)) {
      return this; // Song already exists
    }
    
    return copyWith(
      songs: [...songs, song],
      updatedAt: DateTime.now(),
    );
  }

  /// Add songs to playlist
  EnhancedPlaylist addSongs(List<Song> newSongs) {
    final existingIds = songs.map((s) => s.id).toSet();
    final songsToAdd = newSongs.where((s) => !existingIds.contains(s.id)).toList();
    
    if (songsToAdd.isEmpty) return this;
    
    return copyWith(
      songs: [...songs, ...songsToAdd],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove song from playlist
  EnhancedPlaylist removeSong(String songId) {
    final updatedSongs = songs.where((s) => s.id != songId).toList();
    
    return copyWith(
      songs: updatedSongs,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove songs from playlist
  EnhancedPlaylist removeSongs(List<String> songIds) {
    final idsToRemove = songIds.toSet();
    final updatedSongs = songs.where((s) => !idsToRemove.contains(s.id)).toList();
    
    return copyWith(
      songs: updatedSongs,
      updatedAt: DateTime.now(),
    );
  }

  /// Reorder songs in playlist
  EnhancedPlaylist reorderSongs(int oldIndex, int newIndex) {
    final updatedSongs = List<Song>.from(songs);
    final song = updatedSongs.removeAt(oldIndex);
    updatedSongs.insert(newIndex, song);
    
    return copyWith(
      songs: updatedSongs,
      updatedAt: DateTime.now(),
    );
  }

  /// Shuffle playlist
  EnhancedPlaylist shuffle() {
    final shuffledSongs = List<Song>.from(songs)..shuffle();
    
    return copyWith(
      songs: shuffledSongs,
      updatedAt: DateTime.now(),
    );
  }

  /// Sort playlist by criteria
  EnhancedPlaylist sortBy(PlaylistSortCriteria criteria, {bool ascending = true}) {
    final sortedSongs = List<Song>.from(songs);
    
    switch (criteria) {
      case PlaylistSortCriteria.title:
        sortedSongs.sort((a, b) => ascending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case PlaylistSortCriteria.artist:
        sortedSongs.sort((a, b) => ascending
            ? a.artist.compareTo(b.artist)
            : b.artist.compareTo(a.artist));
        break;
      case PlaylistSortCriteria.album:
        sortedSongs.sort((a, b) => ascending
            ? a.album.compareTo(b.album)
            : b.album.compareTo(a.album));
        break;
      case PlaylistSortCriteria.duration:
        sortedSongs.sort((a, b) => ascending
            ? a.duration.compareTo(b.duration)
            : b.duration.compareTo(a.duration));
        break;
      case PlaylistSortCriteria.dateAdded:
        sortedSongs.sort((a, b) => ascending
            ? a.dateAdded.compareTo(b.dateAdded)
            : b.dateAdded.compareTo(a.dateAdded));
        break;
    }
    
    return copyWith(
      songs: sortedSongs,
      updatedAt: DateTime.now(),
    );
  }

  /// Get playlist statistics
  PlaylistStats get stats {
    if (songs.isEmpty) {
      return PlaylistStats(
        songCount: 0,
        totalDuration: Duration.zero,
        totalSize: 0,
        artists: [],
        albums: [],
        genres: [],
      );
    }

    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (sum, song) => sum + song.duration,
    );

    final totalSize = songs.fold<int>(
      0,
      (sum, song) => sum + song.fileSize,
    );

    final artists = songs.map((s) => s.artist).toSet().toList();
    final albums = songs.map((s) => s.album).toSet().toList();
    final genres = songs.map((s) => s.genre).whereType<String>().toSet().toList();

    return PlaylistStats(
      songCount: songs.length,
      totalDuration: totalDuration,
      totalSize: totalSize,
      artists: artists,
      albums: albums,
      genres: genres,
    );
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final duration = stats.totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Check if playlist is empty
  bool get isEmpty => songs.isEmpty;

  /// Check if playlist is not empty
  bool get isNotEmpty => songs.isNotEmpty;

  /// Check if playlist can be edited
  bool get canEdit => type == PlaylistType.user || isCollaborative;

  /// Check if playlist is smart/auto-generated
  bool get isSmart => type == PlaylistType.smart;

  /// Get playlist cover image or generate one
  String? get effectiveCoverImage {
    if (coverImagePath != null) return coverImagePath;
    
    // Use first song's album art as cover
    final songWithArt = songs.isNotEmpty
        ? songs.firstWhere(
            (song) => song.albumArtPath != null,
            orElse: () => songs.first,
          )
        : null;
    
    return songWithArt?.albumArtPath;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedPlaylist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'EnhancedPlaylist(id: $id, name: $name, songs: ${songs.length})';
  }
}

/// Playlist type enumeration
enum PlaylistType {
  user,     // User-created playlist
  smart,    // Auto-generated smart playlist
  favorite, // Favorite songs playlist
  recent,   // Recently played playlist
  mostPlayed, // Most played songs playlist
}

/// Playlist sort criteria
enum PlaylistSortCriteria {
  title,
  artist,
  album,
  duration,
  dateAdded,
}

/// Playlist statistics
class PlaylistStats {
  final int songCount;
  final Duration totalDuration;
  final int totalSize;
  final List<String> artists;
  final List<String> albums;
  final List<String> genres;

  const PlaylistStats({
    required this.songCount,
    required this.totalDuration,
    required this.totalSize,
    required this.artists,
    required this.albums,
    required this.genres,
  });

  /// Get formatted file size
  String get formattedSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get unique artist count
  int get artistCount => artists.length;

  /// Get unique album count
  int get albumCount => albums.length;

  /// Get unique genre count
  int get genreCount => genres.length;
}

/// Playlist operation result
class PlaylistOperationResult {
  final bool success;
  final String? error;
  final EnhancedPlaylist? playlist;

  const PlaylistOperationResult({
    required this.success,
    this.error,
    this.playlist,
  });

  factory PlaylistOperationResult.success(EnhancedPlaylist playlist) {
    return PlaylistOperationResult(
      success: true,
      playlist: playlist,
    );
  }

  factory PlaylistOperationResult.failure(String error) {
    return PlaylistOperationResult(
      success: false,
      error: error,
    );
  }
}