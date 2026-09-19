# Ruang Tenang Mobile

Aplikasi Flutter mobile-first untuk member Ruang Tenang. Mobile memakai API bersama dengan web, tetapi tidak menyediakan role admin atau mitra. Fokusnya adalah self-care harian, konten, komunitas, chat AI, billing, dan gamifikasi member.

## Mulai cepat

### Prasyarat

- Flutter stable yang kompatibel dengan Dart SDK pada pubspec.yaml.
- Android Studio/SDK untuk Android atau Xcode untuk iOS.
- API Ruang Tenang berjalan dan dapat dijangkau device/emulator.

### Instalasi dan run

```bash
flutter pub get
cp .env.example .env
flutter run
```

.env dimuat sebagai asset lokal. Untuk CI atau build release, gunakan --dart-define:

```bash
flutter run --dart-define=ENVIRONMENT=development --dart-define=BASE_URL=http://10.0.2.2:8080
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com
```

BASE_URL adalah host API tanpa suffix /api/v1; aplikasi menambahkan prefix tersebut sendiri. Android emulator biasanya memakai 10.0.2.2, iOS simulator memakai localhost, dan physical device memerlukan IP LAN komputer yang menjalankan API.

## Perintah verifikasi

```bash
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --release
```

Perubahan UI, routing, datasource, atau config minimal harus melewati analyze dan test. Build APK diperlukan untuk perubahan platform, asset, release, atau CI.

## Arsitektur

- lib/core/: config, constants, DI, network, router, theme, dan utilities.
- lib/data/: remote datasource, model, dan repository implementation.
- lib/domain/: entity, abstract repository, dan use case.
- lib/presentation/: BLoC/Cubit serta screen/widget per feature.
- assets/: font, icon, image, dan Lottie yang didaftarkan di pubspec.yaml.
- test/: unit/config dan widget smoke test.

Alur standar adalah screen → BLoC/Cubit → use case/repository → remote datasource → ApiClient. Detail teknis ada di context/; aturan agent ada di AGENTS.md.

## Fitur member

Home, jurnal, mood tracker/check-in, chat AI, musik/playlist, artikel, stories, forum, wellness, global search, statistik komunitas, billing/premium, profil/settings, dan gamifikasi berupa daily tasks, badge, leaderboard, progress map, rewards, EXP history, XP boost, serta game offline Mindful Runner.

Admin dan mitra memakai web. Jangan menambahkan screen mobile yang memerlukan role tersebut tanpa keputusan produk baru.

## Konfigurasi

Prioritas konfigurasi adalah:

1. --dart-define dari CI/build.
2. .env lokal.
3. fallback platform-aware untuk development.

Variable utama:

| Variable | Kegunaan |
| --- | --- |
| ENVIRONMENT | development, staging, atau production. |
| BASE_URL | Host API tanpa /api/v1. |

Jangan commit .env, token, credential, atau data pengguna. AppConfig adalah sumber kebenaran; AppEnvironment hanya facade kompatibilitas.

## Navigasi

Lima tab shell utama adalah Home, Journal, Chat, Music, dan Profile. Route fitur lain berada di luar shell dan diakses dari Home/Profile/Game Hub. AppRouter secure-by-default: hanya splash, onboarding, dan auth yang public; route lain membutuhkan sesi authenticated.

## CI dan release

Workflow .github/workflows/build-apk.yml memakai Java 17 dan Flutter stable, menjalankan analyze, membangun APK development dan production dengan repository variables BASE_URL_DEVELOPMENT serta BASE_URL_PRODUCTION, mengunggah artifact, lalu memperbarui GitHub Release latest pada push ke main.

Signing production, store publishing, dan credential release tidak disimpan di repository.
