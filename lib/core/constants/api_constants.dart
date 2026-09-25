import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  // Base URL - centralized in AppConfig (dart-define -> .env -> default)
  static String get baseUrl => AppConfig.baseUrl;
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String updatePassword = '/auth/password';

  // Upload
  static const String uploadImage = '/upload/image';
  static const String uploadAudio = '/upload/audio';

  // Articles
  static const String articles = '/articles';
  static const String articleCategories = '/article-categories';

  // Chat
  static const String chatSessions = '/chat-sessions';
  static const String chatMessages = '/chat-messages';

  // Journal
  static const String journals = '/journals';
  static const String journalSearch = '/journals/search';

  // Mood
  static const String userMoods = '/user-moods';
  static const String userMoodToday = '/user-moods/today';
  static const String userMoodLatest = '/user-moods/latest';
  static const String userMoodStats = '/user-moods/stats';

  // Music
  static const String songCategories = '/song-categories';
  static const String playlists = '/playlists';

  // Forum
  static const String forums = '/forums';
  static const String forumCategories = '/forum-categories';
  static const String posts = '/posts';

  // Stories
  static const String stories = '/stories';

  // Wellness
  static const String wellness = '/wellness';

  // Gamification
  static const String dailyTasks = '/daily-tasks';
  static const String badges = '/badges';
  static const String map = '/map';
  static const String expHistory = '/exp-history';
  static const String rewards = '/rewards';
  static const String xpBoost = '/xp-boost';
  static const String combo = '/combo';
  static const String community = '/community';

  // Billing
  static const String billing = '/billing';

  // Search
  static const String search = '/search';
}
