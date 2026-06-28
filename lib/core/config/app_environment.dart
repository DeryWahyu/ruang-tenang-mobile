import 'dart:io' show Platform;

/// Environment configuration for the app.
///
/// Easily switch between environments:
/// - Android Emulator: uses 10.0.2.2 (maps to host machine's localhost)
/// - iOS Simulator: uses localhost (maps to host machine's localhost)
/// - Physical Device: uses your machine's local IP address
/// - Production: uses the production API URL
enum Environment {
  development,
  staging,
  production,
}

class AppEnvironment {
  AppEnvironment._();

  // ┌──────────────────────────────────────────────────────────
  // │ CHANGE THIS to switch environments
  // └──────────────────────────────────────────────────────────
  static const Environment current = Environment.development;

  // ┌──────────────────────────────────────────────────────────
  // │ For PHYSICAL DEVICE testing, change this to your
  // │ computer's local IP address (e.g., 192.168.1.100)
  // │
  // │ Find your IP:
  // │   Windows: ipconfig
  // │   Mac/Linux: ifconfig | grep inet
  // └──────────────────────────────────────────────────────────
  static const String _localDeviceIp = '192.168.18.189';

  /// Set to TRUE when running on a PHYSICAL device (uses your machine's LAN IP).
  /// Set to FALSE when running on the Android emulator (uses 10.0.2.2).
  static const bool usePhysicalDevice = true;

  /// Port the Go backend runs on
  static const int _apiPort = 8080;

  /// Get the correct base URL based on environment & platform
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return _developmentUrl;
      case Environment.staging:
        return 'https://staging-api.ruangtenang.id';
      case Environment.production:
        return 'https://api.ruangtenang.id';
    }
  }

  static String get _developmentUrl {
    try {
      if (Platform.isAndroid) {
        // Physical device uses the host machine's LAN IP; emulator uses 10.0.2.2
        return usePhysicalDevice
            ? physicalDeviceUrl
            : 'http://10.0.2.2:$_apiPort';
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost directly; physical device uses LAN IP
        return usePhysicalDevice ? physicalDeviceUrl : 'http://localhost:$_apiPort';
      } else {
        // Desktop or other platforms
        return 'http://localhost:$_apiPort';
      }
    } catch (_) {
      // Fallback for web or test environments
      return 'http://localhost:$_apiPort';
    }
  }

  /// Use this URL when testing on a physical device
  /// connected to the same WiFi network as your dev machine
  static String get physicalDeviceUrl =>
      'http://$_localDeviceIp:$_apiPort';

  /// Whether to enable debug logging for API calls
  static bool get isDebug => current == Environment.development;

  /// Whether to use strict SSL verification
  static bool get useStrictSSL => current == Environment.production;
}
