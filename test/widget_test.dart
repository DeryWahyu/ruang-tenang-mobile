// Smoke test: verifies the app can be constructed without errors.
//
// The default Flutter counter test was replaced because this app uses
// RuangTenangApp (with DI + GoRouter), not the generated counter template.
// DI must be initialised (as main() does) before the widget tree builds,
// otherwise SplashScreen's GetIt lookups throw.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruang_tenang_mobile/app.dart';
import 'package:ruang_tenang_mobile/core/di/injection_container.dart';
import 'package:ruang_tenang_mobile/core/utils/date_utils.dart';

void main() {
  testWidgets('App smoke test — builds without throwing', (WidgetTester tester) async {
    // Initialise dependencies the same way main() does.
    await initDependencies();
    await AppDateUtils.init();

    await tester.pumpWidget(const RuangTenangApp());

    // Allow the first frame (router redirect) to settle.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
