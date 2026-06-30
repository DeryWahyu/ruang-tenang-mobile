import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/utils/date_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load centralized configuration (.env) before anything reads it.
  await AppConfig.init();

  // Set preferred orientations — dukung potret & lanskap agar nyaman di
  // tablet dan saat perangkat diputar.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize dependencies
  await initDependencies();

  // Initialize date formatting for Indonesian locale
  await AppDateUtils.init();

  runApp(const RuangTenangApp());
}
