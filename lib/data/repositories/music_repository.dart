import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../data/models/album.dart';
import '../../data/services/music_scanner_service.dart';

/// Repository for music data operations
class MusicRepository {
  final MusicScannerService _scannerService;

  MusicRepository(this._scannerService);

  /// Scan device for music files
  Future<List<Song>> scanMusicFiles() async {
    return _scannerService.scanMusicFiles();
  }

  /// Get music files from specific directory
  Future<List<Song>> scanDirectory(String directoryPath) async {
    return _scannerService.scanDirectory(directoryPath);
  }

  /// Check storage permission
  Future<bool> hasStoragePermission() async {
    return _scannerService.hasStoragePermission();
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    return _scannerService.requestStoragePermission();
  }

  /// Get music files count in directory
  Future<int> getMusicFilesCount(String directoryPath) async {
    return _scannerService.getMusicFilesCount(directoryPath);
  }

  /// Filter songs by search query
  List<Song> searchSongs(List<Song> songs, String query) {
    if (query.isEmpty) return songs;

    final lowercaseQuery = query.toLowerCase();
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
             song.artist.toLowerCase().contains(lowercaseQuery) ||
             song.album.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get songs by artist
  List<Song> getSongsByArtist(List<Song> songs, String artist) {
    return songs.where((song) => song.artist == artist).toList();
  }

  /// Get songs by album
  List<Song> getSongsByAlbum(List<Song> songs, String album) {
    return songs.where((song) => song.album == album).toList();
  }

  /// Get songs by genre
  List<Song> getSongsByGenre(List<Song> songs, String genre) {
    return songs.where((song) => song.genre == genre).toList();
  }

  /// Create albums from songs
  List<Album> createAlbumsFromSongs(List<Song> songs) {
    final albumMap = <String, List<Song>>{};

    for (final song in songs) {
      final albumKey = '${song.artist}_${song.album}';
      albumMap.putIfAbsent(albumKey, () => []).add(song);
    }

    return albumMap.values
        .where((songs) => songs.isNotEmpty)
        .map((songs) => Album.fromSongs(songs))
        .toList();
  }

  /// Sort songs by different criteria
  List<Song> sortSongs(List<Song> songs, SortCriteria criteria) {
    final sortedSongs = List<Song>.from(songs);

    switch (criteria) {
      case SortCriteria.title:
        sortedSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortCriteria.artist:
        sortedSongs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SortCriteria.album:
        sortedSongs.sort((a, b) => a.album.compareTo(b.album));
        break;
      case SortCriteria.duration:
        sortedSongs.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case SortCriteria.dateAdded:
        sortedSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortCriteria.fileSize:
        sortedSongs.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
    }

    return sortedSongs;
  }

  /// Get unique artists from songs
  List<String> getUniqueArtists(List<Song> songs) {
    return songs.map((song) => song.artist).toSet().toList()..sort();
  }

  /// Get unique albums from songs
  List<String> getUniqueAlbums(List<Song> songs) {
    return songs.map((song) => song.album).toSet().toList()..sort();
  }

  /// Get unique genres from songs
  List<String> getUniqueGenres(List<Song> songs) {
    return songs
        .where((song) => song.genre != null)
        .map((song) => song.genre!)
        .toSet()
        .toList()..sort();
  }
}

/// Sort criteria for songs
enum SortCriteria {
  title,
  artist,
  album,
  duration,
  dateAdded,
  fileSize,
}

/// Extension methods for sort criteria
extension SortCriteriaExtension on SortCriteria {
  String get displayName {
    switch (this) {
      case SortCriteria.title:
        return 'Title';
      case SortCriteria.artist:
        return 'Artist';
      case SortCriteria.album:
        return 'Album';
      case SortCriteria.duration:
        return 'Duration';
      case SortCriteria.dateAdded:
        return 'Date Added';
      case SortCriteria.fileSize:
        return 'File Size';
    }
  }
}