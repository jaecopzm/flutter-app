import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

/// Navigation item for the bottom navigation bar
class NavigationItem {
  final String label;
  final IconData icon;
  final int index;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.index,
  });
}

/// Bottom navigation bar for the music player
class MusicBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MusicBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavigationItem> items = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home_rounded,
      index: 0,
    ),
    NavigationItem(
      label: 'Library',
      icon: Icons.library_music_rounded,
      index: 1,
    ),
    NavigationItem(
      label: 'Search',
      icon: Icons.search_rounded,
      index: 2,
    ),
    NavigationItem(
      label: 'Playlists',
      icon: Icons.playlist_play_rounded,
      index: 3,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBlack.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.glassOverlay.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentElectric,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentElectric.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}