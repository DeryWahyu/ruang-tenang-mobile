# Testing dan Release
## Local checks

Jalankan flutter pub get, flutter analyze --no-fatal-infos --no-fatal-warnings, dan flutter test. Test saat ini mencakup AppConfig resolution dan widget smoke. Tambahkan test ketika parser, guard, mapping, atau invariant penting berubah.

## Build

Agent tidak menjalankan build lokal otomatis setelah perubahan kode, aset, config, atau platform. Tunggu permintaan build eksplisit dari pengguna. Perintah berikut dipakai saat pengguna meminta build atau saat menyiapkan release yang memang diminta.

Untuk Android gunakan flutter build apk --release. CI membangun dua artifact:
- ruang-tenang-development.apk dengan ENVIRONMENT=development dan BASE_URL_DEVELOPMENT;
- ruang-tenang-production.apk dengan ENVIRONMENT=production dan BASE_URL_PRODUCTION.

Workflow memakai Java 17 dan Flutter stable version yang ditentukan di YAML. GitHub variables harus berisi host-only API URL tanpa /api/v1.

## Platform

Android application ID dan iOS bundle identifier saat ini mengikuti template project; perubahan identifier adalah keputusan release, bukan refactor biasa. Signing key, provisioning, store account, dan release credential berada di luar repository.

## Failure reporting

Jika analyze/test gagal karena warning/error code, dokumentasikan output relevan. Jika gagal karena Flutter cache read-only, SDK, device, atau dependency network, pisahkan sebagai environment blocker dan jangan mengubah source hanya untuk menghindarinya.
