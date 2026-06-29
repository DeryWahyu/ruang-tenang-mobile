// Unit tests for AppConfig resolution logic.
//
// Note: `--dart-define` values are compile-time constants and are empty in
// the test runner, so these tests cover the `.env` layer and the safe
// default fallback (the two layers controllable at runtime).

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_tenang_mobile/core/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig.baseUrl', () {
    test('uses BASE_URL from .env when provided', () {
      dotenv.testLoad(fileInput: 'BASE_URL=https://api.example.com\n'
          'ENVIRONMENT=production');

      expect(AppConfig.baseUrl, 'https://api.example.com');
      expect(AppConfig.apiBaseUrl, 'https://api.example.com/api/v1');
      expect(AppConfig.environment, Environment.production);
      expect(AppConfig.useStrictSSL, isTrue);
      expect(AppConfig.isDebug, isFalse);
    });

    test('strips a trailing slash from BASE_URL', () {
      dotenv.testLoad(fileInput: 'BASE_URL=https://api.example.com/');

      expect(AppConfig.baseUrl, 'https://api.example.com');
      expect(AppConfig.apiBaseUrl, 'https://api.example.com/api/v1');
    });

    test('falls back to a localhost default when BASE_URL is empty', () {
      dotenv.testLoad(fileInput: 'BASE_URL=\nENVIRONMENT=development');

      // Default fallback always targets the local API port.
      expect(AppConfig.baseUrl, contains(':8080'));
      expect(AppConfig.environment, Environment.development);
      expect(AppConfig.isDebug, isTrue);
    });
  });

  group('Environment.fromString', () {
    test('maps known aliases', () {
      expect(Environment.fromString('prod'), Environment.production);
      expect(Environment.fromString('production'), Environment.production);
      expect(Environment.fromString('staging'), Environment.staging);
      expect(Environment.fromString('dev'), Environment.development);
      expect(Environment.fromString(null), Environment.development);
      expect(Environment.fromString('unknown'), Environment.development);
    });
  });
}
