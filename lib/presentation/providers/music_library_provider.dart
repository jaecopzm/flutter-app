import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../data/models/album.dart';
import '../../data/services/music_scanner_service.dart';
import '../../data/repositories/music_repository.dart';

/// Music library state
class MusicLibraryState {
  final List<Song> allSongs;
  final List<Playlist> playlists;
  final List<Album> albums;
  final List<Song> favoriteSongs;
  final List<Song> recentlyPlayedSongs;
  final bool isScanning;
  final String? scanError;
  final DateTime? lastScanTime;

  MusicLibraryState({
    this.allSongs = const [],
    this.playlists = const [],
    this.albums = const [],
    this.favoriteSongs = const [],
    this.recentlyPlayedSongs = const [],
    this.isScanning = false,
    this.scanError,
    this.lastScanTime,
  });

  MusicLibraryState copyWith({
    List<Song>? allSongs,
    List<Playlist>? playlists,
    List<Album>? albums,
    List<Song>? favoriteSongs,
    List<Song>? recentlyPlayedSongs,
    bool? isScanning,
    String? scanError,
    DateTime? lastScanTime,
  }) {
    return MusicLibraryState(
      allSongs: allSongs ?? this.allSongs,
      playlists: playlists ?? this.playlists,
      albums: albums ?? this.albums,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      recentlyPlayedSongs: recentlyPlayedSongs ?? this.recentlyPlayedSongs,
      isScanning: isScanning ?? this.isScanning,
      scanError: scanError ?? this.scanError,
      lastScanTime: lastScanTime ?? this.lastScanTime,
    );
  }

  /// Get songs by artist
  List<Song> getSongsByArtist(String artist) {
    return allSongs.where((song) => song.artist == artist).toList();
  }

  /// Get songs by album
  List<Song> getSongsByAlbum(String album) {
    return allSongs.where((song) => song.album == album).toList();
  }

  /// Get songs by genre
  List<Song> getSongsByGenre(String genre) {
    return allSongs.where((song) => song.genre == genre).toList();
  }

  /// Search songs by query
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return allSongs;

    final lowercaseQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
             song.artist.toLowerCase().contains(lowercaseQuery) ||
             song.album.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get all unique artists
  List<String> get allArtists {
    return allSongs.map((song) => song.artist).toSet().toList()..sort();
  }

  /// Get all unique albums
  List<String> get allAlbums {
    return allSongs.map((song) => song.album).toSet().toList()..sort();
  }

  /// Get all unique genres
  List<String> get allGenres {
    return allSongs
        .where((song) => song.genre != null)
        .map((song) => song.genre!)
        .toSet()
        .toList()..sort();
  }

  /// Get user-created playlists (excluding system playlists)
  List<Playlist> get userPlaylists {
    return playlists.where((playlist) => playlist.type == PlaylistType.user).toList();
  }

  /// Get system playlists
  List<Playlist> get systemPlaylists {
    return playlists.where((playlist) => playlist.type != PlaylistType.user).toList();
  }

  /// Backward compatibility getter for songs
  List<Song> get songs => allSongs;
}

/// Music library notifier
class MusicLibraryNotifier extends StateNotifier<MusicLibraryState> {
  final MusicRepository _repository;

  MusicLibraryNotifier(this._repository) : super(MusicLibraryState()) {
    _initializeSystemPlaylists();
  }

  void _initializeSystemPlaylists() {
    final systemPlaylists = [
      SystemPlaylists.createFavoritesPlaylist(),
      SystemPlaylists.createRecentlyPlayedPlaylist(),
      SystemPlaylists.createAllSongsPlaylist(),
    ];

    state = state.copyWith(playlists: systemPlaylists);
  }

  /// Scan music files from device
  Future<void> scanMusicFiles() async {
    try {
      state = state.copyWith(isScanning: true, scanError: null);

      final hasPermission = await _repository.hasStoragePermission();
      if (!hasPermission) {
        final granted = await _repository.requestStoragePermission();
        if (!granted) {
          throw Exception('Storage permission denied');
        }
      }

      final songs = await _repository.scanMusicFiles();
      addSongs(songs);

      state = state.copyWith(isScanning: false);
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        scanError: e.toString(),
      );
    }
  }

  /// Add songs to library
  void addSongs(List<Song> songs) {
    final updatedSongs = [...state.allSongs, ...songs];
    final updatedAlbums = _generateAlbumsFromSongs(updatedSongs);

    state = state.copyWith(
      allSongs: updatedSongs,
      albums: updatedAlbums,
      lastScanTime: DateTime.now(),
    );

    _updateSystemPlaylists();
  }

  /// Remove song from library
  void removeSong(String songId) {
    final updatedSongs = state.allSongs.where((song) => song.id != songId).toList();
    final updatedAlbums = _generateAlbumsFromSongs(updatedSongs);

    state = state.copyWith(
      allSongs: updatedSongs,
      albums: updatedAlbums,
    );

    _updateSystemPlaylists();
  }

  /// Update song metadata
  void updateSong(Song updatedSong) {
    final updatedSongs = state.allSongs.map((song) {
      return song.id == updatedSong.id ? updatedSong : song;
    }).toList();

    final updatedAlbums = _generateAlbumsFromSongs(updatedSongs);

    state = state.copyWith(
      allSongs: updatedSongs,
      albums: updatedAlbums,
    );

    _updateSystemPlaylists();
  }

  /// Create new playlist
  void createPlaylist(String name, {String description = ''}) {
    final newPlaylist = Playlist(
      name: name,
      description: description,
      type: PlaylistType.user,
    );

    state = state.copyWith(
      playlists: [...state.playlists, newPlaylist],
    );
  }

  /// Delete playlist
  void deletePlaylist(String playlistId) {
    state = state.copyWith(
      playlists: state.playlists.where((playlist) => playlist.id != playlistId).toList(),
    );
  }

  /// Add song to playlist
  void addSongToPlaylist(String playlistId, String songId) {
    final updatedPlaylists = state.playlists.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.addSong(songId);
      }
      return playlist;
    }).toList();

    state = state.copyWith(playlists: updatedPlaylists);
  }

  /// Remove song from playlist
  void removeSongFromPlaylist(String playlistId, String songId) {
    final updatedPlaylists = state.playlists.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.removeSong(songId);
      }
      return playlist;
    }).toList();

    state = state.copyWith(playlists: updatedPlaylists);
  }

  /// Toggle favorite status for a song
  void toggleFavorite(String songId) {
    final song = state.allSongs.firstWhere((song) => song.id == songId);
    final isCurrentlyFavorite = state.favoriteSongs.contains(song);

    final updatedFavorites = isCurrentlyFavorite
        ? state.favoriteSongs.where((s) => s.id != songId).toList()
        : [...state.favoriteSongs, song];

    state = state.copyWith(favoriteSongs: updatedFavorites);
    _updateSystemPlaylists();
  }

  /// Add song to recently played
  void addToRecentlyPlayed(Song song) {
    final updatedRecentlyPlayed = [song, ...state.recentlyPlayedSongs]
        .where((s) => s.id != song.id)
        .take(50) // Keep only last 50 songs
        .toList();

    state = state.copyWith(recentlyPlayedSongs: updatedRecentlyPlayed);
    _updateSystemPlaylists();
  }

  /// Clear recently played
  void clearRecentlyPlayed() {
    state = state.copyWith(recentlyPlayedSongs: []);
    _updateSystemPlaylists();
  }

  /// Set scanning state
  void setScanning(bool isScanning, {String? error}) {
    state = state.copyWith(
      isScanning: isScanning,
      scanError: error,
    );
  }

  /// Generate albums from songs
  List<Album> _generateAlbumsFromSongs(List<Song> songs) {
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

  /// Update system playlists with current data
  void _updateSystemPlaylists() {
    final updatedPlaylists = state.playlists.map((playlist) {
      switch (playlist.id) {
        case SystemPlaylists.favorites:
          return playlist.copyWith(songIds: state.favoriteSongs.map((s) => s.id).toList());
        case SystemPlaylists.recentlyPlayed:
          return playlist.copyWith(songIds: state.recentlyPlayedSongs.map((s) => s.id).toList());
        case SystemPlaylists.allSongs:
          return playlist.copyWith(songIds: state.allSongs.map((s) => s.id).toList());
        default:
          return playlist;
      }
    }).toList();

    state = state.copyWith(playlists: updatedPlaylists);
  }
}

/// Music scanner service provider
final musicScannerServiceProvider = Provider<MusicScannerService>((ref) {
  return MusicScannerService();
});

/// Music repository provider
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final scannerService = ref.watch(musicScannerServiceProvider);
  return MusicRepository(scannerService);
});

/// Music library provider
final musicLibraryProvider = StateNotifierProvider<MusicLibraryNotifier, MusicLibraryState>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return MusicLibraryNotifier(repository);
});

/// Convenience providers
final allSongsProvider = Provider<List<Song>>((ref) {
  return ref.watch(musicLibraryProvider).allSongs;
});

final playlistsProvider = Provider<List<Playlist>>((ref) {
  return ref.watch(musicLibraryProvider).playlists;
});

final albumsProvider = Provider<List<Album>>((ref) {
  return ref.watch(musicLibraryProvider).albums;
});

final favoriteSongsProvider = Provider<List<Song>>((ref) {
  return ref.watch(musicLibraryProvider).favoriteSongs;
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  return ref.watch(musicLibraryProvider).recentlyPlayedSongs;
});

/// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final library = ref.watch(musicLibraryProvider);
  return library.searchSongs(query);
});