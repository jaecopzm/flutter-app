import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../data/models/song.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/enhanced_snackbar.dart';

/// Enhanced playlists screen with YouTube Music + Spotify design
class EnhancedPlaylistsScreen extends ConsumerStatefulWidget {
  const EnhancedPlaylistsScreen({super.key});

  @override
  ConsumerState<EnhancedPlaylistsScreen> createState() => _EnhancedPlaylistsScreenState();
}

class _EnhancedPlaylistsScreenState extends ConsumerState<EnhancedPlaylistsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
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
          child: CustomScrollView(
            slivers: [
              // App bar
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
                            'Your Playlists',
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
              
              // Content
              SliverToBoxAdapter(
                child: _buildContent(libraryState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(libraryState) {
    if (libraryState.isLoading) {
      return _buildLoadingState();
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create new playlist
          _buildCreatePlaylistCard(),
          
          const SizedBox(height: 24),
          
          // Quick playlists section
          Text(
            'Made for you',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildQuickPlaylists(libraryState),
          
          const SizedBox(height: 32),
          
          // Recently created
          Text(
            'Recently created',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildRecentPlaylists(),
          
          const SizedBox(height: 32),
          
          // Auto playlists
          Text(
            'Smart playlists',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildAutoPlaylists(libraryState),
          
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildCreatePlaylistCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: _createNewPlaylist,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Create icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColorsV2.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsV2.dynamicPrimary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Playlist',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColorsV2.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build your perfect mix of songs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsV2.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColorsV2.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPlaylists(libraryState) {
    final quickPlaylists = [
      PlaylistItem(
        'Liked Songs',
        '${libraryState.songs.length} songs',
        Icons.favorite_rounded,
        AppColorsV2.error,
        isLiked: true,
      ),
      PlaylistItem(
        'Recently Played',
        'Your latest tracks',
        Icons.history_rounded,
        AppColorsV2.info,
      ),
      PlaylistItem(
        'Most Played',
        'Your top favorites',
        Icons.trending_up_rounded,
        AppColorsV2.warmOrange,
      ),
    ];

    return Column(
      children: quickPlaylists.map((playlist) => _buildQuickPlaylistTile(playlist)).toList(),
    );
  }

  Widget _buildQuickPlaylistTile(PlaylistItem playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _openPlaylist(playlist),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Playlist cover
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: playlist.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: playlist.isLiked 
                      ? Border.all(color: playlist.color.withValues(alpha: 0.5), width: 2)
                      : null,
                ),
                child: Icon(
                  playlist.icon,
                  color: playlist.color,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Playlist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsV2.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      playlist.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorsV2.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Play button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: playlist.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _playPlaylist(playlist),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: playlist.color,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPlaylists() {
    return Column(
      children: [
        _buildEmptyRecentPlaylists(),
      ],
    );
  }

  Widget _buildEmptyRecentPlaylists() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColorsV2.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.playlist_add_rounded,
              color: AppColorsV2.onSurfaceVariant,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No playlists yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorsV2.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first playlist to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColorsV2.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPlaylists(libraryState) {
    final autoPlaylists = [
      PlaylistItem(
        'Discover Weekly',
        'Your weekly music discovery',
        Icons.auto_awesome_rounded,
        AppColorsV2.neonPurple,
      ),
      PlaylistItem(
        'Daily Mix 1',
        'Your favorite songs mixed with new discoveries',
        Icons.shuffle_rounded,
        AppColorsV2.coolMint,
      ),
      PlaylistItem(
        'Release Radar',
        'New releases from artists you follow',
        Icons.new_releases_rounded,
        AppColorsV2.dynamicSecondary,
      ),
      PlaylistItem(
        'On Repeat',
        'Songs you can\'t stop playing',
        Icons.repeat_rounded,
        AppColorsV2.warmOrange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: autoPlaylists.length,
      itemBuilder: (context, index) {
        return _buildAutoPlaylistCard(autoPlaylists[index]);
      },
    );
  }

  Widget _buildAutoPlaylistCard(PlaylistItem playlist) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _openPlaylist(playlist),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist cover
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      playlist.color,
                      playlist.color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: playlist.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PlaylistPatternPainter(playlist.color),
                      ),
                    ),
                    
                    // Icon
                    Center(
                      child: Icon(
                        playlist.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    // Play button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Playlist info
            Text(
              playlist.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsV2.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              playlist.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColorsV2.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColorsV2.dynamicPrimary),
            SizedBox(height: 16),
            Text(
              'Loading playlists...',
              style: TextStyle(color: AppColorsV2.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _createNewPlaylist() {
    _showCreatePlaylistDialog();
  }

  void _openPlaylist(PlaylistItem playlist) {
    EnhancedSnackbar.showInfo(
      context,
      message: 'Opening ${playlist.title}...',
    );
  }

  void _playPlaylist(PlaylistItem playlist) {
    final libraryState = ref.read(musicLibraryProvider);
    if (libraryState.songs.isNotEmpty) {
      final audioPlayer = ref.read(audioPlayerProvider.notifier);
      final songs = List<Song>.from(libraryState.songs);
      
      // Shuffle for some playlists
      if (playlist.title.contains('Mix') || playlist.title.contains('Shuffle')) {
        songs.shuffle();
      }
      
      audioPlayer.playSong(songs.first);
      
      EnhancedSnackbar.showSuccess(
        context,
        message: 'Playing ${playlist.title}',
      );
    }
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsV2.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColorsV2.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Create Playlist',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColorsV2.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                labelStyle: TextStyle(color: AppColorsV2.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColorsV2.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColorsV2.dynamicPrimary, width: 2),
                ),
              ),
              style: TextStyle(color: AppColorsV2.onSurface),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: AppColorsV2.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColorsV2.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColorsV2.dynamicPrimary, width: 2),
                ),
              ),
              style: TextStyle(color: AppColorsV2.onSurface),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColorsV2.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop();
                // TODO: Implement actual playlist creation
                EnhancedSnackbar.showSuccess(
                  context,
                  message: 'Playlist "$name" created successfully!',
                );
              } else {
                EnhancedSnackbar.showWarning(
                  context,
                  message: 'Please enter a playlist name',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsV2.dynamicPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Playlist item data class
class PlaylistItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLiked;

  PlaylistItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color, {
    this.isLiked = false,
  });
}

/// Custom painter for playlist background patterns
class _PlaylistPatternPainter extends CustomPainter {
  final Color color;

  _PlaylistPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw some decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.15,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      size.width * 0.1,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.2),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}