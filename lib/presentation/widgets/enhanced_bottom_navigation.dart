import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors_v2.dart';
import '../../core/theme/app_theme_v2.dart';

/// Enhanced bottom navigation bar inspired by YouTube Music + Spotify
class EnhancedBottomNavigation extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<EnhancedBottomNavigation> createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends ConsumerState<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemControllers;

  static const List<NavigationItem> _items = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      index: 0,
    ),
    NavigationItem(
      label: 'Your Library',
      icon: Icons.library_music_outlined,
      activeIcon: Icons.library_music_rounded,
      index: 1,
    ),
    NavigationItem(
      label: 'Search',
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      index: 2,
    ),
    NavigationItem(
      label: 'Playlists',
      icon: Icons.queue_music_outlined,
      activeIcon: Icons.queue_music_rounded,
      index: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _itemControllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: AppAnimations.fast,
        vsync: this,
      ),
    );
    
    // Animate in the active item
    _itemControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(EnhancedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(widget.currentIndex);
    }
  }

  void _animateToIndex(int index) {
    for (int i = 0; i < _itemControllers.length; i++) {
      if (i == index) {
        _itemControllers[i].forward();
      } else {
        _itemControllers[i].reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColorsV2.surface,
        border: Border(
          top: BorderSide(
            color: AppColorsV2.glassBorder.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.map((item) {
              return _buildNavigationItem(item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item) {
    final isActive = widget.currentIndex == item.index;
    final controller = _itemControllers[item.index];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => widget.onTap(item.index),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container with animated background
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      curve: AppAnimations.emphasizedCurve,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColorsV2.dynamicPrimary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedSwitcher(
                        duration: AppAnimations.fast,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          key: ValueKey('${item.index}_$isActive'),
                          color: isActive
                              ? AppColorsV2.dynamicPrimary
                              : AppColorsV2.onSurfaceSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Label with animation
                    AnimatedDefaultTextStyle(
                      duration: AppAnimations.fast,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? AppColorsV2.dynamicPrimary
                            : AppColorsV2.onSurfaceSecondary,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Navigation item data class
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int index;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.index,
  });
}