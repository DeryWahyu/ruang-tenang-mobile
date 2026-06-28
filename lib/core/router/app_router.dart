import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/journal.dart';
import '../../domain/entities/breathing.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/bloc/auth_state.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/forgot_password_screen.dart';
import '../../presentation/auth/screens/reset_password_screen.dart';
import '../../presentation/onboarding/screens/onboarding_screen.dart';
import '../../presentation/home/screens/home_screen.dart';
import '../../presentation/common/layouts/main_layout.dart';
import '../../presentation/journal/screens/journal_list_screen.dart';
import '../../presentation/journal/screens/journal_create_screen.dart';
import '../../presentation/journal/screens/journal_detail_screen.dart';
import '../../presentation/mood/screens/mood_tracker_screen.dart';
import '../../presentation/mood/screens/mood_stats_screen.dart';
import '../../presentation/chat/screens/chat_list_screen.dart';
import '../../presentation/chat/screens/chat_detail_screen.dart';
import '../../presentation/music/screens/music_home_screen.dart';
import '../../presentation/music/screens/playlist_detail_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/profile/screens/edit_profile_screen.dart';
import '../../presentation/profile/screens/change_password_screen.dart';
import '../../presentation/profile/screens/settings_screen.dart';
import '../../presentation/splash_screen.dart';

import '../../presentation/breathing/screens/breathing_list_screen.dart';
import '../../presentation/breathing/screens/breathing_session_screen.dart';
import '../../presentation/forum/screens/forum_list_screen.dart';
import '../../presentation/forum/screens/forum_detail_screen.dart';
import '../../presentation/story/screens/story_list_screen.dart';
import '../../presentation/story/screens/story_detail_screen.dart';
import '../../presentation/article/screens/article_list_screen.dart';
import '../../presentation/article/screens/article_detail_screen.dart';

import '../../presentation/gamification/screens/game_hub_screen.dart';
import '../../presentation/gamification/screens/badge_screen.dart';
import '../../presentation/gamification/screens/chest_screen.dart';
import '../../presentation/gamification/screens/daily_spin_screen.dart';
import '../../presentation/gamification/screens/daily_tasks_screen.dart';
import '../../presentation/gamification/screens/exp_history_screen.dart';
import '../../presentation/gamification/screens/leaderboard_screen.dart';
import '../../presentation/gamification/screens/progress_map_screen.dart';
import '../../presentation/gamification/screens/rewards_screen.dart';
import '../../presentation/gamification/screens/guild_screen.dart';
import '../../presentation/gamification/screens/streak_society_screen.dart';
import '../../presentation/gamification/screens/timed_challenge_screen.dart';
import '../../presentation/gamification/screens/xp_boost_screen.dart';
import '../../presentation/gamification/screens/friend_quest_screen.dart';
import '../../presentation/gamification/screens/weekly_league_screen.dart';
import '../../presentation/billing/screens/premium_plans_screen.dart';
import '../../presentation/wellness/screens/wellness_onboarding_screen.dart';
import '../../presentation/wellness/screens/wellness_plan_screen.dart';
import '../../presentation/search/screens/global_search_screen.dart';
import '../../presentation/explore/screens/explore_screen.dart';
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter({required Listenable refreshListenable}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authState = sl<AuthBloc>().state;
        final loc = state.matchedLocation;

        if (authState.status == AuthStatus.initial) return '/splash';

        final isAuthenticated = authState.isAuthenticated;

        if (loc == '/splash') {
          if (isAuthenticated) return '/home';
          final hasSeen = sl<SharedPreferences>().getBool(StorageKeys.hasSeenOnboarding) ?? false;
          return hasSeen ? '/login' : '/onboarding';
        }

        if (loc == '/onboarding') {
          if (isAuthenticated) return '/home';
          return null;
        }

        final isPrivate = loc == '/home' ||
            loc.startsWith('/journal') ||
            loc == '/chat' ||
            loc.startsWith('/music') ||
            loc.startsWith('/profile') ||
            loc.startsWith('/mood') ||
            loc.startsWith('/breathing') ||
            loc.startsWith('/forum') ||
            loc.startsWith('/stories') ||
            loc.startsWith('/articles');

        final isAuthRoute = loc == '/login' ||
            loc == '/register' ||
            loc == '/forgot-password' ||
            loc == '/reset-password';

        if (isPrivate && !isAuthenticated) {
          final hasSeen = sl<SharedPreferences>().getBool(StorageKeys.hasSeenOnboarding) ?? false;
          return hasSeen ? '/login' : '/onboarding';
        }

        if (isAuthRoute && isAuthenticated) return '/home';

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
            final token = state.uri.queryParameters['token'] ?? '';
            return ResetPasswordScreen(token: token);
          },
        ),
        GoRoute(
          path: '/mood',
          builder: (context, state) => const MoodTrackerScreen(),
        ),
        GoRoute(
          path: '/mood/stats',
          builder: (context, state) => const MoodStatsScreen(),
        ),

        // Breathing
        GoRoute(
          path: '/breathing',
          builder: (context, state) => const BreathingListScreen(),
          routes: [
            GoRoute(
              path: 'session',
              builder: (context, state) {
                final technique = state.extra as BreathingTechnique?;
                return BreathingSessionScreen(technique: technique);
              },
            ),
          ],
        ),

        // Forum
        GoRoute(
          path: '/forum',
          builder: (context, state) => const ForumListScreen(),
          routes: [
            GoRoute(
              path: ':slug',
              builder: (context, state) => ForumDetailScreen(
                slug: state.pathParameters['slug']!,
              ),
            ),
          ],
        ),

        // Stories
        GoRoute(
          path: '/stories',
          builder: (context, state) => const StoryListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => StoryDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),

        // Articles
        GoRoute(
          path: '/articles',
          builder: (context, state) => const ArticleListScreen(),
          routes: [
            GoRoute(
              path: ':slug',
              builder: (context, state) => ArticleDetailScreen(
                slug: state.pathParameters['slug']!,
              ),
            ),
          ],
        ),

        // Gamification & Premium
        GoRoute(
          path: '/gamification',
          builder: (context, state) => const GameHubScreen(),
          routes: [
            GoRoute(
              path: 'badges',
              builder: (context, state) => const BadgeScreen(),
            ),
            GoRoute(
              path: 'chests',
              builder: (context, state) => const ChestScreen(),
            ),
            GoRoute(
              path: 'spin',
              builder: (context, state) => const DailySpinScreen(),
            ),
            GoRoute(
              path: 'daily-tasks',
              builder: (context, state) => const DailyTasksScreen(),
            ),
            GoRoute(
              path: 'exp-history',
              builder: (context, state) => const ExpHistoryScreen(),
            ),
            GoRoute(
              path: 'leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: 'progress-map',
              builder: (context, state) => const ProgressMapScreen(),
            ),
            GoRoute(
              path: 'rewards',
              builder: (context, state) => const RewardsScreen(),
            ),
            GoRoute(
              path: 'guild',
              builder: (context, state) => const GuildScreen(),
            ),
            GoRoute(
              path: 'streak-society',
              builder: (context, state) => const StreakSocietyScreen(),
            ),
            GoRoute(
              path: 'timed-challenge',
              builder: (context, state) => const TimedChallengeScreen(),
            ),
            GoRoute(
              path: 'xp-boost',
              builder: (context, state) => const XpBoostScreen(),
            ),
            GoRoute(
              path: 'friend-quest',
              builder: (context, state) => const FriendQuestScreen(),
            ),
            GoRoute(
              path: 'weekly-league',
              builder: (context, state) => const WeeklyLeagueScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/music/playlist/:uuid',
          builder: (context, state) => PlaylistDetailScreen(
            uuid: state.pathParameters['uuid']!,
          ),
        ),
        GoRoute(
          path: '/billing/premium',
          builder: (context, state) => const PremiumPlansScreen(),
        ),
        // Wellness
        GoRoute(
          path: '/wellness/onboarding',
          builder: (context, state) => const WellnessOnboardingScreen(),
        ),
        GoRoute(
          path: '/wellness/plan',
          builder: (context, state) => const WellnessPlanScreen(),
        ),
        // Search
        GoRoute(
          path: '/search',
          builder: (context, state) => const GlobalSearchScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/profile/password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/profile/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/journal',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: JournalListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) {
                    final journal = state.extra as Journal?;
                    return JournalCreateScreen(
                      uuid: journal?.uuid,
                      journal: journal,
                    );
                  },
                ),
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) => JournalDetailScreen(
                    uuid: state.pathParameters['uuid']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => ChatDetailScreen(initialPrompt: state.extra as String?),
                ),
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) => ChatDetailScreen(
                    uuid: state.pathParameters['uuid']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/music',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MusicHomeScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}