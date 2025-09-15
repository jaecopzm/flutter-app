/// Application-wide constants
class AppConstants {
  // App information
  static const String appName = 'Music Player';
  static const String appVersion = '1.0.0';

  // File extensions supported
  static const List<String> supportedAudioExtensions = [
    '.mp3',
    '.flac',
    '.m4a',
    '.aac',
    '.ogg',
    '.wav',
    '.wma'
  ];

  // Audio quality settings
  static const int defaultSampleRate = 44100;
  static const int highQualitySampleRate = 96000;

  // UI Constants
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Player constants
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 0.7;

  // Seek intervals
  static const Duration seekForwardInterval = Duration(seconds: 10);
  static const Duration seekBackwardInterval = Duration(seconds: 10);

  // Storage keys
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyVolume = 'volume_level';
  static const String storageKeyShuffle = 'shuffle_enabled';
  static const String storageKeyRepeat = 'repeat_mode';
  static const String storageKeyFavorites = 'favorite_songs';
  static const String storageKeyRecentlyPlayed = 'recently_played';
  static const String storageKeyPlaylists = 'user_playlists';

  // Notification channels
  static const String notificationChannelId = 'music_player_channel';
  static const String notificationChannelName = 'Music Player';
  static const String notificationChannelDescription = 'Music playback controls';

  // Equalizer bands (basic implementation)
  static const List<double> equalizerBands = [
    32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000
  ];

  // Sleep timer options (in minutes)
  static const List<int> sleepTimerOptions = [15, 30, 45, 60, 90, 120];

  // Search debounce delay
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // Cache settings
  static const Duration metadataCacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 100; // Maximum cached songs

  // Permission request messages
  static const String storagePermissionTitle = 'Storage Access Required';
  static const String storagePermissionMessage =
      'This app needs access to your storage to scan and play music files.';
  static const String storagePermissionDenied =
      'Storage permission is required to access your music library.';
}