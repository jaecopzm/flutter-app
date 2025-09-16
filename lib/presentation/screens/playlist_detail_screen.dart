import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../core/animations/advanced_animations.dart';
import '../../data/models/enhanced_playlist.dart';
import '../providers/playlist_management_provider.dart';
import '../providers/dynamic_theme_provider.dart';
import '../widgets/draggable_playlist_view.dart';
import '../widgets/enhanced_snackbar.dart';

/// Playlist detail screen with drag-and-drop management
class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
  });

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen>
    with TickerProviderStateMixin {
  
  bool _isEditing = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistManagementProvider.notifier)
        .getPlaylist(widget.playlistId);
    
    if (playlist == null) {
      return _buildNotFoundScreen();
    }

    final backgroundGradient = ref.watch(backgroundGradientProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(playlist),
              
              // Playlist content
              Expanded(
                child: DraggablePlaylistView(
                  playlist: playlist,
                  isEditing: _isEditing,
                  onEditToggle: _toggleEditing,
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating action button
      floatingActionButton: _isEditing ? null : AdvancedAnimations.floatingAction(
        animation: _fabController,
        child: FloatingActionButton(
          onPressed: _showAddSongsDialog,
          backgroundColor: ref.watch(currentPaletteProvider).primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppBar(EnhancedPlaylist playlist) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          AdvancedAnimations.rippleButton(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColorsV2.surfaceContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColorsV2.onSurfaceVariant,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              playlist.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColorsV2.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Options menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColorsV2.onSurfaceVariant,
            ),
            onSelected: (value) => _handleMenuAction(value, playlist),
            itemBuilder: (context) => [
              if (playlist.canEdit) ...[
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded),
                      SizedBox(width: 12),
                      Text('Edit Playlist'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded),
                      SizedBox(width: 12),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColorsV2.backgroundGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.playlist_remove_rounded,
                size: 80,
                color: AppColorsV2.onSurfaceVariant,
              ),
              SizedBox(height: 16),
              Text(
                'Playlist not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColorsV2.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _handleMenuAction(String action, EnhancedPlaylist playlist) {
    switch (action) {
      case 'edit':
        _showEditDialog(playlist);
        break;
      case 'duplicate':
        _duplicatePlaylist(playlist);
        break;
      case 'delete':
        _showDeleteDialog(playlist);
        break;
      case 'share':
        _sharePlaylist(playlist);
        break;
    }
  }

  void _showAddSongsDialog() {
    // TODO: Implement add songs dialog
    EnhancedSnackbar.showInfo(
      context,
      message: 'Add songs feature coming soon!',
    );
  }

  void _showEditDialog(EnhancedPlaylist playlist) {
    // TODO: Implement edit playlist dialog
    EnhancedSnackbar.showInfo(
      context,
      message: 'Edit playlist feature coming soon!',
    );
  }

  void _duplicatePlaylist(EnhancedPlaylist playlist) {
    ref.read(playlistManagementProvider.notifier)
        .duplicatePlaylist(playlist.id, '${playlist.name} (Copy)');
    
    EnhancedSnackbar.showSuccess(
      context,
      message: 'Playlist duplicated successfully!',
    );
  }

  void _showDeleteDialog(EnhancedPlaylist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePlaylist(playlist);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePlaylist(EnhancedPlaylist playlist) {
    ref.read(playlistManagementProvider.notifier)
        .deletePlaylist(playlist.id);
    
    Navigator.of(context).pop();
    
    EnhancedSnackbar.showSuccess(
      context,
      message: 'Playlist deleted successfully!',
    );
  }

  void _sharePlaylist(EnhancedPlaylist playlist) {
    // TODO: Implement playlist sharing
    EnhancedSnackbar.showInfo(
      context,
      message: 'Share playlist feature coming soon!',
    );
  }
}