import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../data/models/song.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/enhanced_snackbar.dart';
import '../../core/services/permission_service.dart';
import 'settings_screen.dart';

/// Enhanced home screen inspired by YouTube Music + Spotify
class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _cardsController;
  late Animation<double> _greetingAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _greetingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: AppAnimations.emphasizedCurve),
    );
    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: AppAnimations.standardCurve),
    );
    
    // Start animations
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _scanMusicLibrary() async {
    // First check and request permissions
    if (!mounted) return;
    
    final permissionResult = await PermissionService.requestStoragePermission(context);
    
    if (!permissionResult.granted) {
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'Storage permission is required to scan for music files',
          action: 'Settings',
          onActionPressed: () => PermissionService.requestStoragePermission(context),
        );
      }
      return;
    }

    // Show scanning progress
    if (mounted) {
      EnhancedSnackbar.showLoading(
        context,
        message: 'Scanning for music files...',
      );
    }

    final libraryNotifier = ref.read(musicLibraryProvider.notifier);
    try {
      await libraryNotifier.scanMusicFiles();
      if (mounted) {
        EnhancedSnackbar.showSuccess(
          context,
          message: 'Music library scanned successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'Failed to scan music library: ${e.toString()}',
          action: 'Retry',
          onActionPressed: _scanMusicLibrary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: AnimatedBuilder(
                  animation: _greetingAnimation,
                  child: _buildAppBar(),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _greetingAnimation.value)),
                      child: Opacity(
                        opacity: _greetingAnimation.value,
                        child: child,
                      ),
                    );
                  },
                ),
              ),
              
              // Main content
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _cardsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
                      child: Opacity(
                        opacity: _cardsAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildContent(libraryState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsV2.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What would you like to listen to?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsV2.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.search_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.settings_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColorsV2.surfaceContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColorsV2.glassBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColorsV2.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MusicLibraryState libraryState) {
    // Handle state properly
    if (libraryState.isScanning) {
      return _buildLoadingContent();
    } else if (libraryState.scanError != null) {
      return _buildErrorContent(libraryState.scanError!);
    } else {
      return _buildLibraryContent(libraryState);
    }
  }

  Widget _buildLibraryContent(MusicLibraryState libraryState) {
    if (libraryState.songs.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick access section
          _buildQuickAccessSection(libraryState.songs),

          const SizedBox(height: 32),

          // Recently played section
          if (libraryState.songs.isNotEmpty) ...[
            _buildSectionHeader('Recently played'),
            const SizedBox(height: 16),
            _buildRecentlyPlayedSection(libraryState.songs),
            const SizedBox(height: 32),
          ],

          // Jump back in section
          _buildSectionHeader('Jump back in'),
          const SizedBox(height: 16),
          _buildJumpBackInSection(libraryState.songs),

          const SizedBox(height: 32),

          // Made for you section
          _buildSectionHeader('Made for you'),
          const SizedBox(height: 16),
          _buildMadeForYouSection(libraryState.songs),

          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(List<Song> songs) {
    final shuffledSongs = List<Song>.from(songs)..shuffle(Random(42));
    final quickAccessSongs = shuffledSongs.take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < quickAccessSongs.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  quickAccessSongs[i],
                  delay: i * 50,
                ),
              ),
              const SizedBox(width: 12),
              if (i + 1 < quickAccessSongs.length)
                Expanded(
                  child: _buildQuickAccessCard(
                    quickAccessSongs[i + 1],
                    delay: (i + 1) * 50,
                  ),
                ),
            ],
          ),
          if (i + 2 < quickAccessSongs.length) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildQuickAccessCard(Song song, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.medium + Duration(milliseconds: delay),
      curve: AppAnimations.emphasizedCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColorsV2.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColorsV2.glassBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _playSong(song),
            child: Row(
              children: [
                // Album art
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    image: song.albumArtPath != null
                        ? DecorationImage(
                            image: FileImage(File(song.albumArtPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: song.albumArtPath == null
                        ? AppColorsV2.cardGradient
                        : null,
                  ),
                  child: song.albumArtPath == null
                      ? const Icon(
                          Icons.music_note_rounded,
                          color: AppColorsV2.onSurfaceVariant,
                          size: 20,
                        )
                      : null,
                ),
                
                // Song title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsV2.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildRecentlyPlayedSection(List<Song> songs) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: min(10, songs.length),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: 16,
              left: index == 0 ? 0 : 0,
            ),
            child: _buildAlbumCard(songs[index]),
          );
        },
      ),
    );
  }

  Widget _buildJumpBackInSection(List<Song> songs) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: min(8, songs.length),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: 16,
              left: index == 0 ? 0 : 0,
            ),
            child: _buildPlaylistCard(songs.sublist(index, min(index + 5, songs.length))),
          );
        },
      ),
    );
  }

  Widget _buildMadeForYouSection(List<Song> songs) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: 16,
              left: index == 0 ? 0 : 0,
            ),
            child: _buildDiscoverCard(index),
          );
        },
      ),
    );
  }

  Widget _buildAlbumCard(Song song) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColorsV2.shadowMedium,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                          Icons.album_rounded,
                          color: AppColorsV2.onSurfaceVariant,
                          size: 40,
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

  Widget _buildPlaylistCard(List<Song> songs) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist cover (grid of album arts)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColorsV2.surfaceContainer,
            ),
            child: songs.isNotEmpty
                ? _buildPlaylistCover(songs)
                : const Center(
                    child: Icon(
                      Icons.queue_music_rounded,
                      color: AppColorsV2.onSurfaceVariant,
                      size: 40,
                    ),
                  ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Mix • ${songs.length} songs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorsV2.onSurface,
            ),
          ),
          Text(
            songs.map((s) => s.artist).take(3).join(', '),
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

  Widget _buildPlaylistCover(List<Song> songs) {
    final gridSongs = songs.take(4).toList();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index < gridSongs.length) {
            final song = gridSongs[index];
            return song.albumArtPath != null
                ? Image.file(
                    File(song.albumArtPath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppColorsV2.surfaceContainerHigh,
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: AppColorsV2.onSurfaceSecondary,
                      size: 24,
                    ),
                  );
          }
          return Container(
            color: AppColorsV2.surfaceContainerHigh,
          );
        },
      ),
    );
  }

  Widget _buildDiscoverCard(int index) {
    final titles = ['Discover Weekly', 'Release Radar', 'Daily Mix 1', 'Chill Mix', 'Your Top Songs'];
    final colors = [
      AppColorsV2.dynamicPrimary,
      AppColorsV2.dynamicSecondary,
      AppColorsV2.warmOrange,
      AppColorsV2.coolMint,
      AppColorsV2.neonPurple,
    ];
    
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[index % colors.length],
                  colors[index % colors.length].withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            titles[index % titles.length],
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorsV2.onSurface,
            ),
          ),
          Text(
            'Made for you',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColorsV2.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassContainer(
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
                'Start your musical journey',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColorsV2.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan your device to find music files and build your personal library',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsV2.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _scanMusicLibrary,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Scan for Music'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColorsV2.dynamicPrimary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading your music...',
              style: TextStyle(
                color: AppColorsV2.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(Object error) {
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
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsV2.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _scanMusicLibrary,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _playSong(Song song) {
    final audioPlayer = ref.read(audioPlayerProvider.notifier);
    audioPlayer.playSong(song);
  }
}