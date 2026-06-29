import 'app_config.dart';

export 'app_config.dart' show Environment;

/// Backward-compatible facade over [AppConfig].
///
/// Historically the app referenced `AppEnvironment.*` directly. All
/// configuration now lives in [AppConfig] (the single source of truth,
/// sourced from `--dart-define` -> `.env` -> defaults). This class is kept
/// as a thin delegate so existing call-sites keep working.
class AppEnvironment {
  AppEnvironment._();

  /// The currently active environment.
  static Environment get current => AppConfig.environment;

  /// API base URL (host only, WITHOUT the `/api/v1` prefix).
  static String get baseUrl => AppConfig.baseUrl;

  /// Whether to enable debug logging for API calls.
  static bool get isDebug => AppConfig.isDebug;

  /// Whether to use strict SSL verification.
  static bool get useStrictSSL => AppConfig.useStrictSSL;
}
