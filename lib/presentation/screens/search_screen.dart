import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/music_player_bar.dart';
import '../providers/music_library_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/song.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

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
                child: Text(
                  'Search',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassContainer(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists, albums...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                              },
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Results or Suggestions
              Expanded(
                child: _searchQuery.isEmpty
                    ? _buildSearchSuggestions()
                    : _buildSearchResults(searchResults),
              ),

              // Music Player Bar
              const MusicPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final libraryState = ref.watch(musicLibraryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (libraryState.recentlyPlayedSongs.isNotEmpty) ...[
            Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...libraryState.recentlyPlayedSongs.take(5).map(
                  (song) => _buildSuggestionTile(song, 'Recently played'),
                ),
            const SizedBox(height: 24),
          ],

          // Browse Categories
          Text(
            'Browse All',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // Categories Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCategoryCard(
                'Songs',
                '${libraryState.allSongs.length} songs',
                Icons.music_note_rounded,
                AppColors.accentElectric,
              ),
              _buildCategoryCard(
                'Albums',
                '${libraryState.albums.length} albums',
                Icons.album_rounded,
                AppColors.accentPurple,
              ),
              _buildCategoryCard(
                'Artists',
                '${libraryState.allArtists.length} artists',
                Icons.person_rounded,
                AppColors.accentGold,
              ),
              _buildCategoryCard(
                'Playlists',
                '${libraryState.playlists.length} playlists',
                Icons.playlist_play_rounded,
                AppColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Song> results) {
    if (results.isEmpty) {
      return _buildEmptySearchResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return _buildSongResultTile(song);
      },
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(Song song, String subtitle) {
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
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: Icon(
          Icons.play_arrow_rounded,
          color: AppColors.accentElectric,
        ),
        onTap: () {
          // TODO: Play song
        },
      ),
    );
  }

  Widget _buildSongResultTile(Song song) {
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
          '${song.artist} • ${song.album}',
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

  Widget _buildCategoryCard(
      String title, String subtitle, IconData icon, Color color) {
    return GlassContainer(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to category
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
