import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/services/dynamic_theme_service.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../core/animations/advanced_animations.dart';
import '../../data/models/enhanced_playlist.dart';
import '../../data/models/song.dart';
import '../providers/playlist_management_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/dynamic_theme_provider.dart';
import 'glass_container.dart';

/// Draggable playlist view with reordering support
class DraggablePlaylistView extends ConsumerStatefulWidget {
  final EnhancedPlaylist playlist;
  final bool isEditing;
  final VoidCallback? onEditToggle;

  const DraggablePlaylistView({
    super.key,
    required this.playlist,
    this.isEditing = false,
    this.onEditToggle,
  });

  @override
  ConsumerState<DraggablePlaylistView> createState() => _DraggablePlaylistViewState();
}

class _DraggablePlaylistViewState extends ConsumerState<DraggablePlaylistView>
    with TickerProviderStateMixin {
  
  late AnimationController _reorderController;
  late Animation<double> _reorderAnimation;
  
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Song> _songs = [];
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.playlist.songs);
    
    _reorderController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _reorderAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _reorderController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DraggablePlaylistView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlist.id != widget.playlist.id ||
        oldWidget.playlist.songs.length != widget.playlist.songs.length) {
      setState(() {
        _songs = List.from(widget.playlist.songs);
      });
    }
  }

  @override
  void dispose() {
    _reorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    
    return Column(
      children: [
        // Playlist header
        _buildPlaylistHeader(palette),
        
        // Songs list
        Expanded(
          child: widget.isEditing ? _buildReorderableList(palette) : _buildRegularList(palette),
        ),
      ],
    );
  }

  Widget _buildPlaylistHeader(DynamicColorPalette palette) {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Playlist cover and info
          Row(
            children: [
              // Playlist cover
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPlaylistCover(),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Playlist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColorsV2.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (widget.playlist.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.playlist.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColorsV2.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Stats
                    Text(
                      '${widget.playlist.stats.songCount} songs • ${widget.playlist.formattedTotalDuration}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorsV2.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Play button
              Expanded(
                child: AdvancedAnimations.rippleButton(
                  onTap: _playPlaylist,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.secondary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Play',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Shuffle button
              AdvancedAnimations.rippleButton(
                onTap: _shufflePlaylist,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColorsV2.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.shuffle_rounded,
                    color: AppColorsV2.onSurfaceVariant,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Edit button
              if (widget.playlist.canEdit)
                AdvancedAnimations.rippleButton(
                  onTap: widget.onEditToggle ?? () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isEditing 
                          ? palette.primary.withValues(alpha: 0.2)
                          : AppColorsV2.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      widget.isEditing ? Icons.done_rounded : Icons.edit_rounded,
                      color: widget.isEditing 
                          ? palette.primary 
                          : AppColorsV2.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCover() {
    if (widget.playlist.effectiveCoverImage != null) {
      return Image.file(
        File(widget.playlist.effectiveCoverImage!),
        fit: BoxFit.cover,
      );
    }
    
    // Generate a mosaic from first 4 songs
    final songsWithArt = widget.playlist.songs
        .where((song) => song.albumArtPath != null)
        .take(4)
        .toList();
    
    if (songsWithArt.length >= 4) {
      return _buildMosaicCover(songsWithArt);
    }
    
    // Default gradient cover
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.playlist.customColor ?? AppColorsV2.dynamicPrimary,
            AppColorsV2.dynamicSecondary,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.queue_music_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildMosaicCover(List<Song> songs) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index < songs.length) {
          return Image.file(
            File(songs[index].albumArtPath!),
            fit: BoxFit.cover,
          );
        }
        return Container(
          color: AppColorsV2.surfaceContainerHigh,
        );
      },
    );
  }

  Widget _buildRegularList(DynamicColorPalette palette) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        return AdvancedAnimations.staggeredListAnimation(
          index: index,
          child: _buildSongTile(_songs[index], index, palette),
        );
      },
    );
  }

  Widget _buildReorderableList(DynamicColorPalette palette) {
    return ReorderableListView.builder(
      key: _listKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _songs.length,
      onReorder: _onReorder,
      proxyDecorator: _proxyDecorator,
      itemBuilder: (context, index) {
        return _buildDraggableSongTile(_songs[index], index, palette);
      },
    );
  }

  Widget _buildSongTile(Song song, int index, DynamicColorPalette palette) {
    return Container(
      key: ValueKey(song.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playSong(song, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Track number or playing indicator
                SizedBox(
                  width: 32,
                  child: Center(
                    child: _buildTrackIndicator(song, index + 1, palette),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Album art
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: song.albumArtPath != null
                        ? Image.file(
                            File(song.albumArtPath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: AppColorsV2.cardGradient,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.music_note_rounded,
                                color: AppColorsV2.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isCurrentSong(song) 
                              ? palette.primary 
                              : AppColorsV2.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColorsV2.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Duration
                Text(
                  song.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsV2.onSurfaceSecondary,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // More options
                IconButton(
                  onPressed: () => _showSongOptions(song),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColorsV2.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSongTile(Song song, int index, DynamicColorPalette palette) {
    return Container(
      key: ValueKey(song.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            Icon(
              Icons.drag_handle_rounded,
              color: AppColorsV2.onSurfaceVariant,
              size: 20,
            ),
            
            const SizedBox(width: 12),
            
            // Album art
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: song.albumArtPath != null
                    ? Image.file(
                        File(song.albumArtPath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: AppColorsV2.cardGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: AppColorsV2.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsV2.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsV2.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Remove button
            IconButton(
              onPressed: () => _removeSong(song),
              icon: const Icon(
                Icons.remove_circle_outline_rounded,
                color: AppColorsV2.error,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackIndicator(Song song, int trackNumber, DynamicColorPalette palette) {
    if (_isCurrentSong(song)) {
      return Icon(
        Icons.volume_up_rounded,
        color: palette.primary,
        size: 16,
      );
    }
    
    return Text(
      trackNumber.toString(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColorsV2.onSurfaceSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.02,
          child: Transform.rotate(
            angle: animation.value * 0.02,
            child: Opacity(
              opacity: 0.9,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  // Helper methods
  bool _isCurrentSong(Song song) {
    final currentSong = ref.read(currentSongProvider);
    return currentSong?.id == song.id;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final song = _songs.removeAt(oldIndex);
      _songs.insert(newIndex, song);
    });
    
    // Update the playlist
    ref.read(playlistManagementProvider.notifier)
        .reorderSongs(widget.playlist.id, oldIndex, newIndex);
  }

  void _playPlaylist() {
    if (_songs.isNotEmpty) {
      final audioPlayer = ref.read(audioPlayerProvider.notifier);
      audioPlayer.playSong(_songs.first);
    }
  }

  void _shufflePlaylist() {
    if (_songs.isNotEmpty) {
      final shuffledSongs = List<Song>.from(_songs)..shuffle();
      final audioPlayer = ref.read(audioPlayerProvider.notifier);
      audioPlayer.playSong(shuffledSongs.first);
    }
  }

  void _playSong(Song song, int index) {
    final audioPlayer = ref.read(audioPlayerProvider.notifier);
    audioPlayer.playSong(song);
  }

  void _removeSong(Song song) {
    ref.read(playlistManagementProvider.notifier)
        .removeSongFromPlaylist(widget.playlist.id, song.id);
  }

  void _showSongOptions(Song song) {
    // TODO: Implement song options bottom sheet
  }
}