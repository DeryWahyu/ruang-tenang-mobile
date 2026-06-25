import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ───
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ─── Core ───
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<FlutterSecureStorage>(),
      onUnauthorized: () {
        // Will be connected to AuthBloc later
      },
    ),
  );

  // ─── Data Sources ───
  // Will be registered as features are implemented
  // sl.registerLazySingleton<AuthRemoteDataSource>(...);

  // ─── Repositories ───
  // sl.registerLazySingleton<AuthRepository>(...);

  // ─── Use Cases ───
  // sl.registerLazySingleton<LoginUseCase>(...);

  // ─── BLoCs ───
  // sl.registerFactory<AuthBloc>(...);
}
