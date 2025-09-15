import 'song.dart';

/// Represents a music album
class Album {
  final String id;
  final String title;
  final String artist;
  final List<Song> songs;
  final String? coverArtPath;
  final int? year;
  final String? genre;
  final DateTime dateAdded;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.songs,
    this.coverArtPath,
    this.year,
    this.genre,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  /// Create an Album from a list of songs
  factory Album.fromSongs(List<Song> songs) {
    if (songs.isEmpty) {
      throw ArgumentError('Cannot create album from empty song list');
    }

    final firstSong = songs.first;
    final albumTitle = firstSong.album;
    final artist = firstSong.artist;

    // Group songs by album and artist
    final albumSongs = songs.where((song) =>
      song.album == albumTitle && song.artist == artist
    ).toList();

    // Sort songs by track number, then by title
    albumSongs.sort((a, b) {
      if (a.trackNumber != null && b.trackNumber != null) {
        return a.trackNumber!.compareTo(b.trackNumber!);
      }
      return a.title.compareTo(b.title);
    });

    return Album(
      id: '${artist}_$albumTitle'.replaceAll(' ', '_').toLowerCase(),
      title: albumTitle,
      artist: artist,
      songs: albumSongs,
      coverArtPath: albumSongs.firstWhere(
        (song) => song.hasAlbumArt,
        orElse: () => albumSongs.first,
      ).albumArtPath,
      year: albumSongs.first.year,
      genre: albumSongs.first.genre,
    );
  }

  /// Get the total duration of all songs in the album
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    final seconds = totalDuration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  /// Get the number of songs in the album
  int get songCount => songs.length;

  /// Get the total file size of all songs
  int get totalFileSize => songs.fold(0, (total, song) => total + song.fileSize);

  /// Check if album has cover art
  bool get hasCoverArt => coverArtPath != null && coverArtPath!.isNotEmpty;

  /// Get songs sorted by track number
  List<Song> get sortedSongs {
    final sorted = List<Song>.from(songs);
    sorted.sort((a, b) {
      if (a.trackNumber != null && b.trackNumber != null) {
        return a.trackNumber!.compareTo(b.trackNumber!);
      }
      return a.title.compareTo(b.title);
    });
    return sorted;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Album && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Album(id: $id, title: $title, artist: $artist, songs: $songCount)';
  }
}

/// Album with additional metadata for UI display
class AlbumWithMetadata extends Album {
  final int playCount;
  final DateTime? lastPlayed;
  final bool isFavorite;

  AlbumWithMetadata({
    required super.id,
    required super.title,
    required super.artist,
    required super.songs,
    super.coverArtPath,
    super.year,
    super.genre,
    super.dateAdded,
    this.playCount = 0,
    this.lastPlayed,
    this.isFavorite = false,
  });

  /// Create from base Album
  factory AlbumWithMetadata.fromAlbum(
    Album album, {
    int playCount = 0,
    DateTime? lastPlayed,
    bool isFavorite = false,
  }) {
    return AlbumWithMetadata(
      id: album.id,
      title: album.title,
      artist: album.artist,
      songs: album.songs,
      coverArtPath: album.coverArtPath,
      year: album.year,
      genre: album.genre,
      dateAdded: album.dateAdded,
      playCount: playCount,
      lastPlayed: lastPlayed,
      isFavorite: isFavorite,
    );
  }

  /// Mark album as played
  AlbumWithMetadata markAsPlayed() {
    return AlbumWithMetadata(
      id: id,
      title: title,
      artist: artist,
      songs: songs,
      coverArtPath: coverArtPath,
      year: year,
      genre: genre,
      dateAdded: dateAdded,
      playCount: playCount + 1,
      lastPlayed: DateTime.now(),
      isFavorite: isFavorite,
    );
  }

  /// Toggle favorite status
  AlbumWithMetadata toggleFavorite() {
    return AlbumWithMetadata(
      id: id,
      title: title,
      artist: artist,
      songs: songs,
      coverArtPath: coverArtPath,
      year: year,
      genre: genre,
      dateAdded: dateAdded,
      playCount: playCount,
      lastPlayed: lastPlayed,
      isFavorite: !isFavorite,
    );
  }
}
