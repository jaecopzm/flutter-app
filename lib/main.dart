import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme_v2.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/enhanced_main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends ConsumerWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      title: 'Music Player',
      theme: AppThemeV2.darkTheme,
      darkTheme: AppThemeV2.darkTheme,
      themeMode: ThemeMode.dark, // Force dark theme for now
      home: const EnhancedMainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
