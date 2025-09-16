import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../data/models/song.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/glass_container.dart';

/// Enhanced search screen with YouTube Music + Spotify design
class EnhancedSearchScreen extends ConsumerStatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  ConsumerState<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends ConsumerState<EnhancedSearchScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late TextEditingController _searchController;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  
  String _searchQuery = '';
  bool _isSearching = false;
  List<Song> _searchResults = [];
  
  final List<String> _searchCategories = [
    'All', 'Songs', 'Artists', 'Albums', 'Playlists'
  ];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: AppAnimations.emphasizedCurve),
    );
    _searchAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = true;
    });

    final libraryState = ref.read(musicLibraryProvider);
    final allSongs = libraryState.songs;
    
    final results = allSongs.where((song) {
      return song.title.toLowerCase().contains(_searchQuery) ||
             song.artist.toLowerCase().contains(_searchQuery) ||
             song.album.toLowerCase().contains(_searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
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
          child: Column(
            children: [
              // Search header
              AnimatedBuilder(
                animation: _searchAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 * (1 - _searchAnimation.value)),
                    child: Opacity(
                      opacity: _searchAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildSearchHeader(),
              ),
              
              // Search categories
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSearchCategories(),
              ],
              
              // Search results or browse content
              Expanded(
                child: _searchQuery.isEmpty
                    ? _buildBrowseContent(libraryState)
                    : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Search',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search bar
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColorsV2.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'What do you want to listen to?',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColorsV2.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColorsV2.onSurfaceVariant,
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColorsV2.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _searchCategories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: EdgeInsets.only(right: index < _searchCategories.length - 1 ? 12 : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColorsV2.dynamicPrimary 
                        : AppColorsV2.surfaceContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected 
                        ? null 
                        : Border.all(color: AppColorsV2.glassBorder.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      _searchCategories[index],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : AppColorsV2.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowseContent(MusicLibraryState libraryState) {
    if (libraryState.isScanning) {
      return _buildLoadingState();
    }
    if (libraryState.scanError != null) {
      // TODO: Consider a dedicated error UI
      return _buildLoadingState();
    }
    if (libraryState.songs.isEmpty) {
      return _buildEmptyLibraryState();
    }
    return _buildBrowseContentData(libraryState);
  }
  
  Widget _buildBrowseContentData(library) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Browse categories
          Text(
            'Browse all',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Categories grid
          _buildBrowseCategories(),
          
          const SizedBox(height: 32),
          
          // Recent searches (mock)
          Text(
            'Recent searches',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildRecentSearches(),
          
          const SizedBox(height: 32),
          
          // Trending now (mock)
          Text(
            'Trending in your library',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsV2.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildTrendingSongs(library.songs.take(5).toList()),
        ],
      ),
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      BrowseCategory('Pop', AppColorsV2.warmOrange, Icons.trending_up_rounded),
      BrowseCategory('Rock', AppColorsV2.error, Icons.music_note_rounded),
      BrowseCategory('Jazz', AppColorsV2.neonPurple, Icons.piano_rounded),
      BrowseCategory('Classical', AppColorsV2.coolMint, Icons.library_music_rounded),
      BrowseCategory('Electronic', AppColorsV2.dynamicPrimary, Icons.equalizer_rounded),
      BrowseCategory('Hip Hop', AppColorsV2.dynamicSecondary, Icons.mic_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(BrowseCategory category) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _searchByCategory(category.name),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color.withValues(alpha: 0.3),
                      category.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsV2.onSurface,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = ['Rock songs', 'Chill music', 'Classical', 'Workout playlist'];
    
    return Column(
      children: recentSearches.map((search) => _buildRecentSearchTile(search)).toList(),
    );
  }

  Widget _buildRecentSearchTile(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _searchController.text = search;
            _performSearch(search);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColorsV2.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColorsV2.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    search,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColorsV2.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeRecentSearch(search),
                  icon: const Icon(
                    Icons.close_rounded,
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

  Widget _buildTrendingSongs(List<Song> songs) {
    return Column(
      children: songs.map((song) => _buildTrendingSongTile(song)).toList(),
    );
  }

  Widget _buildTrendingSongTile(Song song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
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
                
                // Trending icon
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppColorsV2.dynamicPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorsV2.dynamicPrimary),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return _buildSearchResultTile(song);
      },
    );
  }

  Widget _buildSearchResultTile(Song song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                                size: 24,
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
                
                // More options
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColorsV2.dynamicPrimary),
          SizedBox(height: 16),
          Text(
            'Loading your music...',
            style: TextStyle(color: AppColorsV2.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLibraryState() {
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
                Icons.search_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No music to search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColorsV2.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some music to your library first',
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

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 80,
              color: AppColorsV2.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColorsV2.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsV2.onSurfaceVariant,
              ),
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

  void _searchByCategory(String category) {
    _searchController.text = category;
    _performSearch(category);
  }

  void _removeRecentSearch(String search) {
    // TODO: Implement remove recent search
  }

  void _showSongOptions(Song song) {
    // TODO: Implement song options bottom sheet
  }
}

/// Browse category data class
class BrowseCategory {
  final String name;
  final Color color;
  final IconData icon;

  BrowseCategory(this.name, this.color, this.icon);
}