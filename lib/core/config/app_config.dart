import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supported runtime environments.
enum Environment {
  development,
  staging,
  production;

  static Environment fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }
}

/// Centralized application configuration.
///
/// This is the single source of truth for every environment-specific /
/// important value in the app. Values are resolved with the following
/// priority (highest first):
///
///   1. `--dart-define` values  (injected by CI/CD)
///   2. values from the bundled `.env` file (local development)
///   3. safe defaults (platform-aware localhost for development)
///
/// Always call [AppConfig.init] once during app start-up (before any
/// dependency that reads configuration) — see `main.dart`.
class AppConfig {
  AppConfig._();

  // ──────────────────────────────────────────────────────────
  // Compile-time values (provided via --dart-define in CI/CD)
  // ──────────────────────────────────────────────────────────
  static const String _dartDefineEnvironment =
      String.fromEnvironment('ENVIRONMENT');
  static const String _dartDefineBaseUrl = String.fromEnvironment('BASE_URL');

  // ──────────────────────────────────────────────────────────
  // Local development fallback (used only when nothing else is set)
  // ──────────────────────────────────────────────────────────

  /// For PHYSICAL DEVICE testing, set this to your computer's LAN IP
  /// (e.g. 192.168.1.100). Find it via `ipconfig` (Windows) or
  /// `ifconfig | grep inet` (Mac/Linux).
  static const String _localDeviceIp = '192.168.18.189';

  /// Set to TRUE when running on a PHYSICAL device (uses your machine's
  /// LAN IP). Set to FALSE when running on the Android emulator
  /// (uses 10.0.2.2).
  static const bool usePhysicalDevice = true;

  /// Port the Go backend runs on during local development.
  static const int _apiPort = 8080;

  /// The `/api/v1` style prefix appended to [baseUrl] to form [apiBaseUrl].
  static const String apiPrefix = '/api/v1';

  static bool _initialized = false;

  /// Loads the `.env` file if present. Safe to call when `.env` is missing
  /// (e.g. on CI when only `--dart-define` is used) — it simply falls back
  /// to dart-define values and defaults.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // No .env bundled — rely on --dart-define values and defaults.
    }
    _initialized = true;
  }

  /// Reads a value with priority: dart-define -> .env -> null.
  static String? _read(String dartDefineValue, String key) {
    if (dartDefineValue.isNotEmpty) return dartDefineValue;
    final fromEnv = dotenv.isInitialized ? dotenv.maybeGet(key) : null;
    if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
    return null;
  }

  /// The currently active environment.
  static Environment get environment =>
      Environment.fromString(_read(_dartDefineEnvironment, 'ENVIRONMENT'));

  /// The API base URL (host only, WITHOUT the [apiPrefix]).
  ///
  /// Resolves from dart-define -> .env -> platform-aware localhost default.
  static String get baseUrl {
    final configured = _read(_dartDefineBaseUrl, 'BASE_URL');
    if (configured != null) {
      // Strip any trailing slash so apiBaseUrl concatenation is clean.
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }
    return _localFallbackUrl;
  }

  /// Full API base URL including the [apiPrefix] (e.g. `https://host/api/v1`).
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  /// Platform-aware localhost URL used when no base URL is configured.
  static String get _localFallbackUrl {
    try {
      if (Platform.isAndroid) {
        return usePhysicalDevice
            ? 'http://$_localDeviceIp:$_apiPort'
            : 'http://10.0.2.2:$_apiPort';
      } else if (Platform.isIOS) {
        return usePhysicalDevice
            ? 'http://$_localDeviceIp:$_apiPort'
            : 'http://localhost:$_apiPort';
      }
      return 'http://localhost:$_apiPort';
    } catch (_) {
      // Web or test environments.
      return 'http://localhost:$_apiPort';
    }
  }

  /// Whether to enable verbose debug logging for API calls.
  static bool get isDebug => environment == Environment.development;

  /// Whether to use strict SSL verification (enabled in production).
  static bool get useStrictSSL => environment == Environment.production;
}
