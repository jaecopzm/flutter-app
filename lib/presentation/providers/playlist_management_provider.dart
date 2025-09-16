import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/enhanced_playlist.dart';
import '../../data/models/song.dart';

/// Playlist management state
class PlaylistManagementState {
  final List<EnhancedPlaylist> playlists;
  final bool isLoading;
  final String? error;
  final EnhancedPlaylist? selectedPlaylist;

  const PlaylistManagementState({
    this.playlists = const [],
    this.isLoading = false,
    this.error,
    this.selectedPlaylist,
  });

  PlaylistManagementState copyWith({
    List<EnhancedPlaylist>? playlists,
    bool? isLoading,
    String? error,
    EnhancedPlaylist? selectedPlaylist,
  }) {
    return PlaylistManagementState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
    );
  }
}

/// Playlist management notifier
class PlaylistManagementNotifier extends Notifier<PlaylistManagementState> {
  static const String _playlistsKey = 'enhanced_playlists';

  @override
  PlaylistManagementState build() {
    _loadPlaylists();
    return const PlaylistManagementState();
  }

  /// Load playlists from storage
  Future<void> _loadPlaylists() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);
      
      if (playlistsJson != null) {
        final List<dynamic> playlistsList = json.decode(playlistsJson);
        final List<EnhancedPlaylist> playlists = playlistsList
            .map((json) => _playlistFromJson(json))
            .where((playlist) => playlist != null)
            .cast<EnhancedPlaylist>()
            .toList();
        
        state = state.copyWith(
          playlists: playlists,
          isLoading: false,
        );
      } else {
        // Create default playlists
        await _createDefaultPlaylists();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load playlists: $e',
        isLoading: false,
      );
    }
  }

  /// Save playlists to storage
  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = json.encode(
        state.playlists.map((playlist) => _playlistToJson(playlist)).toList(),
      );
      await prefs.setString(_playlistsKey, playlistsJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save playlists: $e');
    }
  }

  /// Create a new playlist
  Future<PlaylistOperationResult> createPlaylist({
    required String name,
    String description = '',
    bool isPublic = false,
    bool isCollaborative = false,
    Color? customColor,
  }) async {
    try {
      // Check if playlist name already exists
      if (state.playlists.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
        return PlaylistOperationResult.failure('Playlist name already exists');
      }

      final EnhancedPlaylist newPlaylist = EnhancedPlaylist.create(
        name: name,
        description: description,
        isPublic: isPublic,
        isCollaborative: isCollaborative,
        customColor: customColor,
      );

      state = state.copyWith(
        playlists: [...state.playlists, newPlaylist],
      );

      await _savePlaylists();
      return PlaylistOperationResult.success(newPlaylist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to create playlist: $e');
    }
  }

  /// Update an existing playlist
  Future<PlaylistOperationResult> updatePlaylist(EnhancedPlaylist updatedPlaylist) async {
    try {
      final int index = state.playlists.indexWhere((p) => p.id == updatedPlaylist.id);
      if (index == -1) {
        return PlaylistOperationResult.failure('Playlist not found');
      }

      final List<EnhancedPlaylist> updatedPlaylists = List<EnhancedPlaylist>.from(state.playlists);
      updatedPlaylists[index] = updatedPlaylist.copyWith(updatedAt: DateTime.now());

      state = state.copyWith(playlists: updatedPlaylists);
      await _savePlaylists();
      
      return PlaylistOperationResult.success(updatedPlaylists[index]);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to update playlist: $e');
    }
  }

  /// Delete a playlist
  Future<PlaylistOperationResult> deletePlaylist(String playlistId) async {
    try {
      final EnhancedPlaylist playlist = state.playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => throw Exception('Playlist not found'),
      );

      // Don't allow deletion of system playlists
      if (playlist.type != PlaylistType.user) {
        return PlaylistOperationResult.failure('Cannot delete system playlists');
      }

      final List<EnhancedPlaylist> updatedPlaylists = state.playlists
          .where((p) => p.id != playlistId)
          .toList();

      state = state.copyWith(playlists: updatedPlaylists);
      await _savePlaylists();
      
      return PlaylistOperationResult.success(playlist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to delete playlist: $e');
    }
  }

  /// Add song to playlist
  Future<PlaylistOperationResult> addSongToPlaylist(String playlistId, Song song) async {
    try {
      final int playlistIndex = state.playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return PlaylistOperationResult.failure('Playlist not found');
      }

      final EnhancedPlaylist playlist = state.playlists[playlistIndex];
      final EnhancedPlaylist updatedPlaylist = playlist.addSong(song);
      
      return await updatePlaylist(updatedPlaylist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to add song: $e');
    }
  }

  /// Add multiple songs to playlist
  Future<PlaylistOperationResult> addSongsToPlaylist(String playlistId, List<Song> songs) async {
    try {
      final int playlistIndex = state.playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return PlaylistOperationResult.failure('Playlist not found');
      }

      final EnhancedPlaylist playlist = state.playlists[playlistIndex];
      final EnhancedPlaylist updatedPlaylist = playlist.addSongs(songs);
      
      return await updatePlaylist(updatedPlaylist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to add songs: $e');
    }
  }

  /// Remove song from playlist
  Future<PlaylistOperationResult> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final int playlistIndex = state.playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return PlaylistOperationResult.failure('Playlist not found');
      }

      final EnhancedPlaylist playlist = state.playlists[playlistIndex];
      final EnhancedPlaylist updatedPlaylist = playlist.removeSong(songId);
      
      return await updatePlaylist(updatedPlaylist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to remove song: $e');
    }
  }

  /// Reorder songs in playlist
  Future<PlaylistOperationResult> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    try {
      final int playlistIndex = state.playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return PlaylistOperationResult.failure('Playlist not found');
      }

      final EnhancedPlaylist playlist = state.playlists[playlistIndex];
      final EnhancedPlaylist updatedPlaylist = playlist.reorderSongs(oldIndex, newIndex);
      
      return await updatePlaylist(updatedPlaylist);
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to reorder songs: $e');
    }
  }

  /// Duplicate a playlist
  Future<PlaylistOperationResult> duplicatePlaylist(String playlistId, String newName) async {
    try {
      final EnhancedPlaylist originalPlaylist = state.playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => throw Exception('Playlist not found'),
      );

      return await createPlaylist(
        name: newName,
        description: 'Copy of ${originalPlaylist.name}',
      ).then((result) async {
        if (result.success && result.playlist != null) {
          final EnhancedPlaylist duplicatedPlaylist = result.playlist!.addSongs(originalPlaylist.songs);
          return await updatePlaylist(duplicatedPlaylist);
        }
        return result;
      });
    } catch (e) {
      return PlaylistOperationResult.failure('Failed to duplicate playlist: $e');
    }
  }

  /// Get playlist by ID
  EnhancedPlaylist? getPlaylist(String playlistId) {
    try {
      return state.playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  /// Get playlists by type
  List<EnhancedPlaylist> getPlaylistsByType(PlaylistType type) {
    return state.playlists.where((p) => p.type == type).toList();
  }

  /// Search playlists
  List<EnhancedPlaylist> searchPlaylists(String query) {
    if (query.trim().isEmpty) return state.playlists;
    
    final String lowercaseQuery = query.toLowerCase();
    return state.playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(lowercaseQuery) ||
             playlist.description.toLowerCase().contains(lowercaseQuery) ||
             playlist.songs.any((song) =>
               song.title.toLowerCase().contains(lowercaseQuery) ||
               song.artist.toLowerCase().contains(lowercaseQuery)
             );
    }).toList();
  }

  /// Select a playlist
  void selectPlaylist(String playlistId) {
    final EnhancedPlaylist? playlist = getPlaylist(playlistId);
    state = state.copyWith(selectedPlaylist: playlist);
  }

  /// Clear selected playlist
  void clearSelectedPlaylist() {
    state = state.copyWith(selectedPlaylist: null);
  }

  /// Create default playlists
  Future<void> _createDefaultPlaylists() async {
    final List<EnhancedPlaylist> defaultPlaylists = [
      EnhancedPlaylist.smart(
        name: 'Favorites',
        description: 'Your liked songs',
        songs: [],
        metadata: {'type': 'favorites'},
      ),
      EnhancedPlaylist.smart(
        name: 'Recently Played',
        description: 'Songs you recently listened to',
        songs: [],
        metadata: {'type': 'recent'},
      ),
      EnhancedPlaylist.smart(
        name: 'Most Played',
        description: 'Your most played tracks',
        songs: [],
        metadata: {'type': 'most_played'},
      ),
    ];

    state = state.copyWith(
      playlists: defaultPlaylists,
      isLoading: false,
    );

    await _savePlaylists();
  }

  /// Convert playlist to JSON
  Map<String, dynamic> _playlistToJson(EnhancedPlaylist playlist) {
    return {
      'id': playlist.id,
      'name': playlist.name,
      'description': playlist.description,
      'songs': playlist.songs.map((song) => song.id).toList(),
      'coverImagePath': playlist.coverImagePath,
      'createdAt': playlist.createdAt.toIso8601String(),
      'updatedAt': playlist.updatedAt.toIso8601String(),
      'createdBy': playlist.createdBy,
      'isPublic': playlist.isPublic,
      'isCollaborative': playlist.isCollaborative,
      'collaborators': playlist.collaborators,
      'metadata': playlist.metadata,
      'type': playlist.type.name,
      'customColor': playlist.customColor?.toARGB32(),
    };
  }

  /// Convert JSON to playlist (simplified - would need song lookup in real implementation)
  EnhancedPlaylist? _playlistFromJson(Map<String, dynamic> json) {
    try {
      return EnhancedPlaylist(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        songs: [], // Would need to look up songs by IDs
        coverImagePath: json['coverImagePath'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        createdBy: json['createdBy'],
        isPublic: json['isPublic'] ?? false,
        isCollaborative: json['isCollaborative'] ?? false,
        collaborators: List<String>.from(json['collaborators'] ?? []),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        type: PlaylistType.values.firstWhere(
          (PlaylistType type) => type.name == json['type'],
          orElse: () => PlaylistType.user,
        ),
        customColor: json['customColor'] != null ? Color(json['customColor'] as int) : null,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Playlist management provider
final playlistManagementProvider = NotifierProvider<PlaylistManagementNotifier, PlaylistManagementState>(() {
  return PlaylistManagementNotifier();
});

/// User playlists provider (convenience)
final userPlaylistsProvider = Provider<List<EnhancedPlaylist>>((ref) {
  return ref.watch(playlistManagementProvider).playlists
      .where((EnhancedPlaylist p) => p.type == PlaylistType.user)
      .toList();
});

/// Smart playlists provider (convenience)
final smartPlaylistsProvider = Provider<List<EnhancedPlaylist>>((ref) {
  return ref.watch(playlistManagementProvider).playlists
      .where((EnhancedPlaylist p) => p.type == PlaylistType.smart)
      .toList();
});

/// Selected playlist provider (convenience)
final selectedPlaylistProvider = Provider<EnhancedPlaylist?>((ref) {
  return ref.watch(playlistManagementProvider).selectedPlaylist;
});