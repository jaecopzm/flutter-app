import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';
import '../widgets/enhanced_bottom_navigation.dart';
import '../widgets/enhanced_music_player_bar.dart';
import '../providers/audio_player_provider.dart';
import 'enhanced_home_screen.dart';
import 'enhanced_library_screen.dart';
import 'enhanced_search_screen.dart';
import 'enhanced_playlists_screen.dart';

/// Enhanced main navigation screen with YouTube Music + Spotify inspiration
class EnhancedMainNavigationScreen extends ConsumerStatefulWidget {
  const EnhancedMainNavigationScreen({super.key});

  @override
  ConsumerState<EnhancedMainNavigationScreen> createState() => _EnhancedMainNavigationScreenState();
}

class _EnhancedMainNavigationScreenState extends ConsumerState<EnhancedMainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;

  final List<Widget> _screens = [
    const EnhancedHomeScreen(),
    const EnhancedLibraryScreen(),
    const EnhancedSearchScreen(),
    const EnhancedPlaylistsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fadeController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      
      // Animate to the new page
      _pageController.animateToPage(
        index,
        duration: AppAnimations.medium,
        curve: AppAnimations.standardCurve,
      );
      
      // Subtle feedback
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final hasCurrentSong = audioState.currentSong != null;
    
    return Scaffold(
      backgroundColor: AppColorsV2.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColorsV2.backgroundGradient,
            ),
          ),
          
          // Main content with page view
          Positioned.fill(
            bottom: hasCurrentSong ? 160 : 80, // Account for mini-player and navigation
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeController,
                  child: child,
                );
              },
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _screens,
              ),
            ),
          ),
          
          // Bottom UI stack
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced mini-player (only show if there's a current song)
                if (hasCurrentSong) ...[
                  const EnhancedMusicPlayerBar(),
                  const SizedBox(height: 8),
                ],
                
                // Enhanced bottom navigation
                EnhancedBottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}