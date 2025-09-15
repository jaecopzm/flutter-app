import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Appearance Section
                    _buildSectionHeader('Appearance'),
                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          'Theme',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          themeState.isDarkMode ? 'Dark' : 'Light',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Switch(
                          value: themeState.isDarkMode,
                          onChanged: (value) => themeNotifier.toggleTheme(),
                          activeTrackColor: AppColors.accentElectric.withValues(alpha: 0.5),
                          activeColor: AppColors.accentElectric,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Playback Section
                    _buildSectionHeader('Playback'),
                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Audio Quality',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          'High Quality',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          // TODO: Show audio quality options
                        },
                      ),
                    ),

                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Equalizer',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          'Customize sound',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          // TODO: Open equalizer
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Library Section
                    _buildSectionHeader('Library'),
                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Scan Music Library',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          'Refresh your music collection',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.accentElectric,
                        ),
                        onTap: () {
                          // TODO: Trigger library scan
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionHeader('About'),
                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Version',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          '1.0.0',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Privacy Policy',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          // TODO: Open privacy policy
                        },
                      ),
                    ),

                    GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text(
                          'Terms of Service',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          // TODO: Open terms of service
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.accentElectric,
        ),
      ),
    );
  }
}