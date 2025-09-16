import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../data/models/song.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/enhanced_snackbar.dart';

/// Enhanced library screen with YouTube Music + Spotify design
class EnhancedLibraryScreen extends ConsumerStatefulWidget {
  const EnhancedLibraryScreen({super.key});

  @override
  ConsumerState<EnhancedLibraryScreen> createState() => _EnhancedLibraryScreenState();
}

class _EnhancedLibraryScreenState extends ConsumerState<EnhancedLibraryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  final List<String> _tabs = ['All', 'Artists', 'Albums', 'Playlists'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _headerController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppAnimations.emphasizedCurve),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final libraryState = ref.watch(musicLibraryProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColorsV2.backgroundGradient,
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App bar with animated header
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -30 * (1 - _headerAnimation.value)),
                        child: Opacity(
                          opacity: _headerAnimation.value,
                          child: FlexibleSpaceBar(
                            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                            title: Text(
                              'Your Library',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColorsV2.onSurface,
                              ),
                            ),
                            background: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColorsV2.surfaceContainerLow,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Tab bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabBar: Container(
                      color: AppColorsV2.surface.withValues(alpha: 0.95),
                      child: TabBar(
                        controller: _tabController,
                        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                        indicatorColor: AppColorsV2.dynamicPrimary,
                        indicatorWeight: 3,
                        labelColor: AppColorsV2.dynamicPrimary,
                        unselectedLabelColor: AppColorsV2.onSurfaceVariant,
                        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overlayColor: WidgetStateProperty.all(
                          AppColorsV2.dynamicPrimary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(libraryState),
                _buildArtistsTab(libraryState),
                _buildAlbumsTab(libraryState),
                _buildPlaylistsTab(libraryState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllTab(MusicLibraryState libraryState) {
    if (libraryState.isScanning) {
      return _buildLoadingState();
    } else if (libraryState.scanError != null) {
      return _buildErrorState(libraryState.scanError!);
    } else {
      if (libraryState.songs.isEmpty) {
        return _buildEmptyState();
      }
      return _buildAllTabContent(libraryState);
    }
  }
  
  Widget _buildAllTabContent(MusicLibraryState libraryState) {

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recently added section
        _buildSectionHeader('Recently Added'),
        const SizedBox(height: 12),
        _buildRecentSongsList(libraryState.songs.take(5).toList()),

        const SizedBox(height: 24),

        // Quick actions
        _buildQuickActions(),

        const SizedBox(height: 24),

        // All songs
        _buildSectionHeader('All Songs'),
        const SizedBox(height: 12),
        ...libraryState.songs.map((song) => _buildSongTile(song)),
      ],
    );
  }

  Widget _buildArtistsTab(MusicLibraryState libraryState) {
    if (libraryState.isScanning) {
      return _buildLoadingState();
    } else if (libraryState.scanError != null) {
      return _buildErrorState(libraryState.scanError!);
    } else {
      if (libraryState.songs.isEmpty) return _buildEmptyState();
      return _buildArtistsTabContent(libraryState);
    }
  }
  
  Widget _buildArtistsTabContent(MusicLibraryState libraryState) {

    // Group songs by artist
    final artistGroups = <String, List<Song>>{};
    for (final song in libraryState.songs) {
      artistGroups.putIfAbsent(song.artist, () => []).add(song);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artistGroups.length,
      itemBuilder: (context, index) {
        final artist = artistGroups.keys.elementAt(index);
        final songs = artistGroups[artist]!;
        return _buildArtistTile(artist, songs);
      },
    );
  }

  Widget _buildAlbumsTab(MusicLibraryState libraryState) {
    if (libraryState.isScanning) {
      return _buildLoadingState();
    } else if (libraryState.scanError != null) {
      return _buildErrorState(libraryState.scanError!);
    } else {
      if (libraryState.songs.isEmpty) return _buildEmptyState();
      return _buildAlbumsTabContent(libraryState);
    }
  }
  
  Widget _buildAlbumsTabContent(MusicLibraryState libraryState) {

    // Group songs by album
    final albumGroups = <String, List<Song>>{};
    for (final song in libraryState.songs) {
      final albumKey = '${song.album}_${song.artist}';
      albumGroups.putIfAbsent(albumKey, () => []).add(song);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: albumGroups.length,
      itemBuilder: (context, index) {
        final songs = albumGroups.values.elementAt(index);
        return _buildAlbumCard(songs);
      },
    );
  }

  Widget _buildPlaylistsTab(MusicLibraryState libraryState) {
    if (libraryState.isScanning) {
      return _buildLoadingState();
    } else if (libraryState.scanError != null) {
      return _buildErrorState(libraryState.scanError!);
    } else {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create playlist button
          _buildCreatePlaylistTile(),
          const SizedBox(height: 16),

          // Favorites (mock)
          _buildPlaylistTile(
            'Liked Songs',
            '${libraryState.songs.length} songs',
            Icons.favorite,
            AppColorsV2.dynamicPrimary,
          ),

        // Recently played (mock)
        _buildPlaylistTile(
          'Recently Played',
          'Auto-playlist',
          Icons.history,
          AppColorsV2.dynamicSecondary,
        ),

        // Most played (mock)
        _buildPlaylistTile(
          'Most Played',
          'Auto-playlist',
          Icons.trending_up,
          AppColorsV2.warmOrange,
        ),
        ],
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColorsV2.onSurface,
      ),
    );
  }

  Widget _buildRecentSongsList(List<Song> songs) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: EdgeInsets.only(right: index < songs.length - 1 ? 12 : 0),
            child: _buildSongCard(songs[index]),
          );
        },
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsV2.shadowMedium,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Song info
          Text(
            song.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorsV2.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            song.artist,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColorsV2.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Shuffle All',
            Icons.shuffle_rounded,
            AppColorsV2.dynamicPrimary,
            () => _shuffleAllSongs(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Download All',
            Icons.download_rounded,
            AppColorsV2.dynamicSecondary,
            () => _downloadAllSongs(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsV2.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playSong(song),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Album art
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsV2.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                        '${song.artist} • ${song.album}',
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
                
                // More button
                IconButton(
                  onPressed: () => _showSongOptions(song),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColorsV2.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtistTile(String artist, List<Song> songs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Artist avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: AppColorsV2.primaryGradient,
              ),
              child: Center(
                child: Text(
                  artist.isNotEmpty ? artist[0].toUpperCase() : 'A',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Artist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsV2.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${songs.length} song${songs.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsV2.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Play button
            IconButton(
              onPressed: () => _playArtistSongs(songs),
              icon: const Icon(
                Icons.play_circle_filled_rounded,
                color: AppColorsV2.dynamicPrimary,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCard(List<Song> songs) {
    final song = songs.first;
    
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsV2.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                            Icons.album_rounded,
                            color: AppColorsV2.onSurfaceVariant,
                            size: 48,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Album info
          Text(
            song.album,
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColorsV2.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${songs.length} song${songs.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColorsV2.onSurfaceSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePlaylistTile() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _createNewPlaylist,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColorsV2.dynamicPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColorsV2.dynamicPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Playlist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsV2.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Make your own mix',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsV2.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _openPlaylist(title),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsV2.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorsV2.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColorsV2.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColorsV2.dynamicPrimary),
          SizedBox(height: 16),
          Text(
            'Loading your library...',
            style: TextStyle(color: AppColorsV2.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColorsV2.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColorsV2.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsV2.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColorsV2.primaryGradient,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.library_music_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your library is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColorsV2.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding some music to your device',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsV2.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _playSong(Song song) {
    final audioPlayer = ref.read(audioPlayerProvider.notifier);
    audioPlayer.playSong(song);
  }

  void _playArtistSongs(List<Song> songs) {
    if (songs.isNotEmpty) {
      final audioPlayer = ref.read(audioPlayerProvider.notifier);
      audioPlayer.playSong(songs.first);
    }
  }

  void _shuffleAllSongs() {
    final library = ref.read(musicLibraryProvider);
    if (library.songs.isNotEmpty) {
      final shuffledSongs = List<Song>.from(library.songs)..shuffle();
      final audioPlayer = ref.read(audioPlayerProvider.notifier);
      audioPlayer.playSong(shuffledSongs.first);
    }
  }

  void _downloadAllSongs() {
    // TODO: Implement download functionality
    EnhancedSnackbar.showInfo(
      context,
      message: 'Download feature coming soon!',
    );
  }

  void _showSongOptions(Song song) {
    // TODO: Implement song options bottom sheet
  }

  void _createNewPlaylist() {
    // TODO: Implement create playlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create playlist feature coming soon!'),
        backgroundColor: AppColorsV2.info,
      ),
    );
  }

  void _openPlaylist(String playlistName) {
    // TODO: Implement playlist navigation
  }
}

/// Custom tab bar delegate for persistent header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tabBar;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}