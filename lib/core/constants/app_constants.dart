class AppConstants {
  AppConstants._();

  static const String appName = 'Ruang Tenang';
  static const String appTagline = 'Platform Kesehatan Mental';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration tokenExpiry = Duration(days: 30);

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Chat
  static const int chatDailyMessageLimit = 50;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Animation
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Mood emojis
  static const List<String> moodLabels = [
    'Happy',
    'Calm',
    'Neutral',
    'Sad',
    'Cry',
    'Angry',
    'Anxious',
    'Stressed',
  ];
}
