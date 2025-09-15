import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/music_player_bar.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'playlists_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const SearchScreen(),
    const PlaylistsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Music player bar (only show if there's current song)
                const MusicPlayerBar(),

                // Navigation bar
                MusicBottomNavigationBar(
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