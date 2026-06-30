import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  // Base URL - centralized in AppConfig (dart-define -> .env -> default)
  static String get baseUrl => AppConfig.baseUrl;
  static const String apiPrefix = AppConfig.apiPrefix;
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  // Health check
  static const String health = '/health';

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
  static const String myArticles = '/my-articles';

  // Chat
  static const String chatSessions = '/chat-sessions';
  static const String chatMessages = '/chat-messages';
  static const String chatFolders = '/chat-folders';
  static const String chatPrompts = '/chat-prompts';

  // Journal
  static const String journals = '/journals';
  static const String journalSearch = '/journals/search';
  static const String journalPrompt = '/journals/prompt';

  // Mood
  static const String userMoods = '/user-moods';
  static const String userMoodToday = '/user-moods/today';
  static const String userMoodLatest = '/user-moods/latest';
  static const String userMoodStats = '/user-moods/stats';

  // Music
  static const String songCategories = '/song-categories';
  static const String songs = '/songs';
  static const String playlists = '/playlists';

  // Forum
  static const String forums = '/forums';
  static const String forumCategories = '/forum-categories';
  static const String posts = '/posts';

  // Stories
  static const String stories = '/stories';

  // Breathing
  static const String breathing = '/breathing';
  static const String breathingTechniques = '/breathing/techniques';
  static const String breathingSessions = '/breathing/sessions';
  static const String breathingStats = '/breathing/stats';
  static const String breathingPreferences = '/breathing/preferences';
  static const String breathingFavorites = '/breathing/favorites';
  static const String breathingCalendar = '/breathing/calendar';
  static const String breathingRecommendations = '/breathing/recommendations';

  // Wellness
  static const String wellness = '/wellness';

  // Gamification
  static const String dailyTasks = '/daily-tasks';
  static const String badges = '/badges';
  static const String features = '/features';
  static const String map = '/map';
  static const String guilds = '/guilds';
  static const String leaderboard = '/leaderboard';
  static const String levelConfigs = '/level-configs';
  static const String expHistory = '/exp-history';
  static const String rewards = '/rewards';
  static const String xpBoost = '/xp-boost';
  static const String combo = '/combo';
  static const String community = '/community';

  // Billing
  static const String billing = '/billing';

  // Notifications
  static const String notifications = '/notifications';
  static const String push = '/push';

  // Search
  static const String search = '/search';

  // User
  static const String user = '/user';

  // Moderation
  static const String reports = '/reports';
  static const String appeals = '/appeals';
  static const String blocks = '/blocks';

  // B2B
  static const String b2b = '/b2b';
}
