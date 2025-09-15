import 'package:uuid/uuid.dart';
import 'song.dart';

/// Represents a user-created playlist
class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> songIds; // References to song IDs
  final DateTime dateCreated;
  final DateTime? dateModified;
  final String? coverArtPath;
  final bool isFavorite;
  final PlaylistType type;

  Playlist({
    String? id,
    required this.name,
    this.description = '',
    List<String>? songIds,
    DateTime? dateCreated,
    this.dateModified,
    this.coverArtPath,
    this.isFavorite = false,
    this.type = PlaylistType.user,
  }) :
    id = id ?? const Uuid().v4(),
    songIds = songIds ?? [],
    dateCreated = dateCreated ?? DateTime.now();

  /// Create a Playlist from JSON data
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      songIds: List<String>.from(json['songIds'] as List? ?? []),
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : null,
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
      coverArtPath: json['coverArtPath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      type: PlaylistType.values[json['type'] as int? ?? 0],
    );
  }

  /// Convert Playlist to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songIds': songIds,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
      'coverArtPath': coverArtPath,
      'isFavorite': isFavorite,
      'type': type.index,
    };
  }

  /// Create a copy of the playlist with updated fields
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? songIds,
    DateTime? dateCreated,
    DateTime? dateModified,
    String? coverArtPath,
    bool? isFavorite,
    PlaylistType? type,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songIds: songIds ?? this.songIds,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      isFavorite: isFavorite ?? this.isFavorite,
      type: type ?? this.type,
    );
  }

  /// Add a song to the playlist
  Playlist addSong(String songId) {
    if (songIds.contains(songId)) return this;
    return copyWith(
      songIds: [...songIds, songId],
      dateModified: DateTime.now(),
    );
  }

  /// Remove a song from the playlist
  Playlist removeSong(String songId) {
    return copyWith(
      songIds: songIds.where((id) => id != songId).toList(),
      dateModified: DateTime.now(),
    );
  }

  /// Add multiple songs to the playlist
  Playlist addSongs(List<String> newSongIds) {
    final uniqueIds = {...songIds, ...newSongIds}.toList();
    return copyWith(
      songIds: uniqueIds,
      dateModified: DateTime.now(),
    );
  }

  /// Clear all songs from the playlist
  Playlist clearSongs() {
    return copyWith(
      songIds: [],
      dateModified: DateTime.now(),
    );
  }

  /// Check if playlist contains a specific song
  bool containsSong(String songId) => songIds.contains(songId);

  /// Get the number of songs in the playlist
  int get songCount => songIds.length;

  /// Check if playlist is empty
  bool get isEmpty => songIds.isEmpty;

  /// Check if playlist has a custom cover art
  bool get hasCustomCover => coverArtPath != null && coverArtPath!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songs: $songCount, type: $type)';
  }
}

/// Types of playlists
enum PlaylistType {
  user,      // User-created playlist
  favorite,  // Favorite songs
  recent,    // Recently played
  system,    // System-generated (e.g., "All Songs")
}

/// Special system playlists
class SystemPlaylists {
  static const String favorites = 'favorites';
  static const String recentlyPlayed = 'recently_played';
  static const String allSongs = 'all_songs';

  static Playlist createFavoritesPlaylist() {
    return Playlist(
      id: favorites,
      name: 'Favorites',
      description: 'Your favorite songs',
      type: PlaylistType.favorite,
    );
  }

  static Playlist createRecentlyPlayedPlaylist() {
    return Playlist(
      id: recentlyPlayed,
      name: 'Recently Played',
      description: 'Songs you\'ve played recently',
      type: PlaylistType.recent,
    );
  }

  static Playlist createAllSongsPlaylist() {
    return Playlist(
      id: allSongs,
      name: 'All Songs',
      description: 'All songs in your library',
      type: PlaylistType.system,
    );
  }
}

/// Playlist with resolved songs (for UI display)
class PlaylistWithSongs {
  final Playlist playlist;
  final List<Song> songs;
  final Duration totalDuration;

  PlaylistWithSongs({
    required this.playlist,
    required this.songs,
  }) : totalDuration = songs.fold(
         Duration.zero,
         (total, song) => total + song.duration,
       );

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    final seconds = totalDuration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get total file size of all songs
  int get totalFileSize => songs.fold(0, (total, song) => total + song.fileSize);

  /// Get formatted total file size
  String get formattedTotalFileSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = totalFileSize.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}