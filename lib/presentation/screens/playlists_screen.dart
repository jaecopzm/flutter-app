import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/music_player_bar.dart';
import '../providers/music_library_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/playlist.dart';

class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(musicLibraryProvider);
    final userPlaylists = libraryState.playlists
        .where((playlist) => playlist.type == PlaylistType.user)
        .toList();

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
                      'Playlists',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showCreatePlaylistDialog(context, ref),
                      icon: Icon(
                        Icons.add_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: userPlaylists.isEmpty
                    ? _buildEmptyState()
                    : _buildPlaylistsList(userPlaylists),
              ),

              // Music Player Bar
              const MusicPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.controlBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.playlist_add_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No playlists yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first playlist to organize your music',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreatePlaylistDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Playlist'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsList(List<Playlist> playlists) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _buildPlaylistCard(playlist);
      },
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openPlaylist(playlist),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Playlist Cover
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.controlBackground,
                ),
                child: Icon(
                  Icons.playlist_play_rounded,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.songIds.length} songs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (playlist.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        playlist.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Menu Button
              IconButton(
                onPressed: () => _showPlaylistMenu(context, playlist),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    _playlistNameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Create Playlist',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: _playlistNameController,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentElectric),
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _playlistNameController.text.trim();
              if (name.isNotEmpty) {
                ref.read(musicLibraryProvider.notifier).createPlaylist(name);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created playlist "$name"')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentElectric,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistMenu(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit_rounded,
              color: AppColors.textSecondary,
            ),
            title: Text(
              'Rename',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showRenamePlaylistDialog(context, playlist);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_rounded,
              color: AppColors.error,
            ),
            title: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showDeletePlaylistDialog(context, playlist);
            },
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, Playlist playlist) {
    _playlistNameController.text = playlist.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Rename Playlist',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: _playlistNameController,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentElectric),
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = _playlistNameController.text.trim();
              if (newName.isNotEmpty && newName != playlist.name) {
                // TODO: Implement rename functionality in provider
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentElectric,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Playlist',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(musicLibraryProvider.notifier).deletePlaylist(playlist.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted playlist "${playlist.name}"')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openPlaylist(Playlist playlist) {
    // TODO: Navigate to playlist detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening playlist "${playlist.name}"')),
    );
  }
}