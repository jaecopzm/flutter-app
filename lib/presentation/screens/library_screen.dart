import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/music_player_bar.dart';
import '../providers/music_library_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/song.dart';
import '../../data/models/album.dart';
import '../../data/models/playlist.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(musicLibraryProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Your Library',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.sort_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${libraryState.allSongs.length}',
                        'Songs',
                        Icons.music_note_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${libraryState.albums.length}',
                        'Albums',
                        Icons.album_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${libraryState.playlists.length}',
                        'Playlists',
                        Icons.playlist_play_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // Tab Bar
                      TabBar(
                        tabs: const [
                          Tab(text: 'Songs'),
                          Tab(text: 'Albums'),
                          Tab(text: 'Playlists'),
                        ],
                        labelColor: AppColors.accentElectric,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.accentElectric,
                        indicatorSize: TabBarIndicatorSize.label,
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSongsTab(libraryState.allSongs),
                            _buildAlbumsTab(libraryState.albums),
                            _buildPlaylistsTab(libraryState.playlists),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Music Player Bar
              const MusicPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return GlassContainer(
      height: 70, // Reduced height
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.accentElectric,
              size: 20, // Smaller icon
            ),
            const SizedBox(height: 2), // Reduced spacing
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith( // Smaller text
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsTab(List<Song> songs) {
    if (songs.isEmpty) {
      return _buildEmptyState('No songs found', 'Scan your music library to get started');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildSongTile(context, song, index);
      },
    );
  }

  Widget _buildSongTile(BuildContext context, Song song, int index) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.controlBackground,
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        title: Text(
          song.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          song.formattedDuration,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        onTap: () {
          // TODO: Play song
        },
      ),
    );
  }

  Widget _buildAlbumsTab(List<Album> albums) {
    if (albums.isEmpty) {
      return _buildEmptyState('No albums found', 'Albums will appear here after scanning');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildAlbumCard(context, album);
      },
    );
  }

  Widget _buildAlbumCard(BuildContext context, Album album) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.controlBackground,
              ),
              child: Icon(
                Icons.album_rounded,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Album Info
          Text(
            album.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Text(
            album.artist,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Text(
            '${album.songCount} songs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(List<Playlist> playlists) {
    final userPlaylists = playlists.where((p) => p.type == PlaylistType.user).toList();

    if (userPlaylists.isEmpty) {
      return _buildEmptyState(
        'No playlists yet',
        'Create your first playlist to organize your music',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userPlaylists.length,
      itemBuilder: (context, index) {
        final playlist = userPlaylists[index];
        return _buildPlaylistTile(context, playlist);
      },
    );
  }

  Widget _buildPlaylistTile(BuildContext context, Playlist playlist) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.controlBackground,
          ),
          child: Icon(
            Icons.playlist_play_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        title: Text(
          playlist.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${playlist.songIds.length} songs',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.more_vert_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          // TODO: Open playlist
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_rounded,
            size: 80,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}