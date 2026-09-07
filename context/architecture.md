# Arsitektur Mobile
## Layer

- lib/presentation/: screen, widget, BLoC, dan Cubit; widget tidak mengakses HTTP langsung.
- lib/domain/: entity, repository contract, dan use case.
- lib/data/: remote datasource, model, dan repository implementation.
- lib/core/network/: Dio ApiClient, interceptor, exception, dan response parser.
- lib/core/di/: GetIt registration. Remote datasource/repository umumnya lazy singleton; BLoC/Cubit umumnya factory.
- lib/core/theme/ dan lib/core/utils/: design system, validator, date, media, error, dan parser.
- lib/core/router/app_router.dart: GoRouter, ShellRoute, route guard, dan global overlay helper.

## Bootstrap

main.dart memastikan Flutter binding, AppConfig.init, orientation/system UI, DI, dan locale date sebelum runApp. RuangTenangApp membangun router, provider BLoC, MaterialApp.router, gradient background, offline banner, mini-player, dan daily task FAB.

## Routing

Splash menunggu auth state. Hanya splash, onboarding, login, register, forgot password, dan reset password yang public. Semua route fitur lain private secara default. Home, journal, chat, music, dan profile berada di ShellRoute; detail/secondary route di-push di atas shell.

## Data flow

Screen mengirim event ke BLoC/Cubit. Use case memanggil repository contract, implementation memanggil datasource, datasource memakai ApiClient dan memetakan model ke entity. Error harus dikonversi menjadi pesan UI yang aman dan actionable.

## Perubahan aman

Perubahan shared ApiClient, interceptor, response parser, DI, router, atau theme berdampak luas. Tambahkan test config/parser/router bila behavior berubah dan periksa semua consumer.
