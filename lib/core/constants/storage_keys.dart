class StorageKeys {
  StorageKeys._();

  // Auth
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';

  // Onboarding
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // Cache
  static const String cachedArticles = 'cached_articles';
  static const String cachedJournals = 'cached_journals';
  static const String cachedMoods = 'cached_moods';

  // Settings
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String aiDisclaimerAccepted = 'ai_disclaimer_accepted';

  // Music Player
  static const String lastPlayedSong = 'last_played_song';
  static const String lastPlayedPlaylist = 'last_played_playlist';
  static const String playerVolume = 'player_volume';
  static const String playerRepeatMode = 'player_repeat_mode';

  // Offline Queue
  static const String offlineQueue = 'offline_queue';
}
