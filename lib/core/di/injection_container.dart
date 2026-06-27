import '../../data/datasources/remote/wellness_remote_datasource.dart';
import '../../data/datasources/remote/search_remote_datasource.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../presentation/wellness/bloc/wellness_bloc.dart';
import '../../presentation/search/bloc/search_bloc.dart';
import '../../domain/repositories/upload_repository.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../data/datasources/remote/gamification_remote_datasource.dart';
import '../../data/datasources/remote/billing_remote_datasource.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../data/repositories/billing_repository_impl.dart';
import '../../presentation/gamification/bloc/gamification_bloc.dart';
import '../../presentation/billing/bloc/billing_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/journal_remote_datasource.dart';
import '../../data/datasources/remote/mood_remote_datasource.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/datasources/remote/breathing_remote_datasource.dart';
import '../../data/datasources/remote/article_remote_datasource.dart';
import '../../data/datasources/remote/forum_remote_datasource.dart';
import '../../data/datasources/remote/story_remote_datasource.dart';
import '../../data/datasources/remote/music_remote_datasource.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/breathing_repository.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/repositories/forum_repository.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/repositories/music_repository.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/breathing_repository_impl.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/forum_repository_impl.dart';
import '../../data/repositories/story_repository_impl.dart';
import '../../data/repositories/music_repository_impl.dart';

import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/auth/login_use_case.dart';
import '../../domain/usecases/auth/register_use_case.dart';
import '../../domain/usecases/auth/forgot_password_use_case.dart';
import '../../domain/usecases/auth/reset_password_use_case.dart';
import '../../domain/usecases/auth/get_profile_use_case.dart';
import '../../domain/usecases/auth/logout_use_case.dart';
import '../../domain/usecases/auth/check_auth_status_use_case.dart';
import '../../domain/usecases/auth/get_cached_user_use_case.dart';

import '../../domain/usecases/journal/journal_usecases.dart';
import '../../domain/usecases/journal/get_journal_list_use_case.dart';
import '../../domain/usecases/journal/search_journals_use_case.dart';
import '../../domain/usecases/journal/get_journal_use_case.dart';
import '../../domain/usecases/journal/create_journal_use_case.dart';
import '../../domain/usecases/journal/update_journal_use_case.dart';
import '../../domain/usecases/journal/delete_journal_use_case.dart';

import '../../domain/usecases/mood/mood_usecases.dart';
import '../../domain/usecases/mood/record_mood_use_case.dart';
import '../../domain/usecases/mood/get_today_mood_use_case.dart';
import '../../domain/usecases/mood/get_latest_mood_use_case.dart';
import '../../domain/usecases/mood/get_mood_history_use_case.dart';
import '../../domain/usecases/mood/get_mood_stats_use_case.dart';

import '../../domain/usecases/chat/chat_usecases.dart';

import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/bloc/auth_event.dart';
import '../../presentation/journal/bloc/journal_bloc.dart';
import '../../presentation/mood/bloc/mood_bloc.dart';
import '../../presentation/chat/bloc/chat_bloc.dart';
import '../../presentation/breathing/bloc/breathing_bloc.dart';
import '../../presentation/article/bloc/article_bloc.dart';
import '../../presentation/forum/bloc/forum_bloc.dart';
import '../../presentation/story/bloc/story_bloc.dart';
import '../../presentation/music/bloc/music_bloc.dart';
import '../../domain/usecases/music/music_usecases.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<FlutterSecureStorage>(),
      onUnauthorized: () {
        if (sl.isRegistered<AuthBloc>()) {
          sl<AuthBloc>().add(const AuthLogoutRequested());
        }
      },
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<JournalRemoteDataSource>(
    () => JournalRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<MoodRemoteDataSource>(
    () => MoodRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<BreathingRemoteDataSource>(
    () => BreathingRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<StoryRemoteDataSource>(
    () => StoryRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<MusicRemoteDataSource>(
    () => MusicRemoteDataSource(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(
      remote: sl<JournalRemoteDataSource>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(
      remote: sl<MoodRemoteDataSource>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remote: sl<ChatRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<BreathingRepository>(
    () => BreathingRepositoryImpl(
      remote: sl<BreathingRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      remote: sl<ArticleRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<ForumRepository>(
    () => ForumRepositoryImpl(
      remote: sl<ForumRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remote: sl<StoryRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(
      remote: sl<MusicRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AuthUseCases(
        login: LoginUseCase(sl()),
        register: RegisterUseCase(sl()),
        forgotPassword: ForgotPasswordUseCase(sl()),
        resetPassword: ResetPasswordUseCase(sl()),
        getProfile: GetProfileUseCase(sl()),
        logout: LogoutUseCase(sl()),
        checkAuthStatus: CheckAuthStatusUseCase(sl()),
        getCachedUser: GetCachedUserUseCase(sl()),
      ));

  sl.registerLazySingleton(() => JournalUseCases(
        getList: GetJournalListUseCase(sl()),
        search: SearchJournalsUseCase(sl()),
        getJournal: GetJournalUseCase(sl()),
        create: CreateJournalUseCase(sl()),
        update: UpdateJournalUseCase(sl()),
        delete: DeleteJournalUseCase(sl()),
      ));

  sl.registerLazySingleton(() => MoodUseCases(
        record: RecordMoodUseCase(sl()),
        getToday: GetTodayMoodUseCase(sl()),
        getLatest: GetLatestMoodUseCase(sl()),
        getHistory: GetMoodHistoryUseCase(sl()),
        getStats: GetMoodStatsUseCase(sl()),
      ));

  sl.registerLazySingleton(() => ChatUseCases(
        getSessions: GetChatSessionsUseCase(sl()),
        getSession: GetChatSessionUseCase(sl()),
        createSession: CreateChatSessionUseCase(sl()),
        deleteSession: DeleteChatSessionUseCase(sl()),
        sendMessage: SendChatMessageUseCase(sl()),
        toggleLikeMessage: ToggleLikeMessageUseCase(sl()),
        toggleDislikeMessage: ToggleDislikeMessageUseCase(sl()),
      ));

  sl.registerLazySingleton(() => GetSongCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetSongsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetPublicPlaylistsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyPlaylistsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlaylistUseCase(sl()));

  // BLoCs
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authUseCases: sl<AuthUseCases>()),
  );

  sl.registerFactory<JournalBloc>(
    () => JournalBloc(journalUseCases: sl<JournalUseCases>()),
  );
  sl.registerFactory<MoodBloc>(
    () => MoodBloc(moodUseCases: sl<MoodUseCases>()),
  );
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatUseCases: sl<ChatUseCases>()),
  );
  sl.registerFactory<BreathingBloc>(
    () => BreathingBloc(repository: sl<BreathingRepository>()),
  );
  sl.registerFactory<ArticleBloc>(
    () => ArticleBloc(repository: sl<ArticleRepository>()),
  );
  sl.registerFactory<ForumBloc>(
    () => ForumBloc(repository: sl<ForumRepository>()),
  );
  sl.registerFactory<StoryBloc>(
    () => StoryBloc(repository: sl<StoryRepository>()),
  );
  sl.registerFactory<MusicBloc>(
    () => MusicBloc(
      getCategories: sl<GetSongCategoriesUseCase>(),
      getSongsByCategory: sl<GetSongsByCategoryUseCase>(),
      getPublicPlaylists: sl<GetPublicPlaylistsUseCase>(),
      getMyPlaylists: sl<GetMyPlaylistsUseCase>(),
      createPlaylist: sl<CreatePlaylistUseCase>(),
      uploadRepository: sl<UploadRepository>(),
    ),
  );

  // === Phase 3: Gamification & Billing ===
  // Remote Data Sources
  sl.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSource(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(remote: sl<GamificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(remote: sl<BillingRemoteDataSource>()),
  );

  // BLoCs
  sl.registerFactory<GamificationBloc>(
    () => GamificationBloc(repository: sl<GamificationRepository>()),
  );
  sl.registerFactory<BillingBloc>(
    () => BillingBloc(repository: sl<BillingRepository>()),
  );

  // === Phase 4: Polish & Advanced ===
  // Remote Data Sources
  sl.registerLazySingleton<WellnessRemoteDataSource>(
    () => WellnessRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<WellnessRepository>(
    () => WellnessRepositoryImpl(remote: sl<WellnessRemoteDataSource>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remote: sl<SearchRemoteDataSource>()),
  );

  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // BLoCs
  sl.registerFactory<WellnessBloc>(
    () => WellnessBloc(repository: sl<WellnessRepository>()),
  );
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(repository: sl<SearchRepository>()),
  );
}