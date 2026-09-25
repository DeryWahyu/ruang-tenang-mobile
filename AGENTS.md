# AGENTS.md — Ruang Tenang Mobile
Dokumen ini adalah instruksi kanonis untuk AI agent dan contributor. Baca README.md, lalu buka context/ sesuai area perubahan.

CLAUDE.md, GEMINI.md, dan .github/copilot-instructions.md adalah adapter tipis yang merujuk ke dokumen ini; Cursor dan OpenCode memakai AGENTS.md sebagai instruction native.

## Sumber kebenaran

- Runtime truth: pubspec.yaml, lib/core/config/app_config.dart, lib/core/router/app_router.dart, DI, workflow CI, dan platform files.
- Product truth: context/product-and-navigation.md; aplikasi hanya untuk role member.
- API truth: datasource/model Dart dibandingkan route dan OpenAPI pada ruang-tenang-api.
- Layering truth: data/domain/presentation yang sudah ada; hindari bypass layer.
- File .orig, .rej, generated Flutter files, dan build output bukan sumber implementasi utama.

## Cara bekerja

1. Baca context yang relevan sebelum mengubah feature.
2. Untuk perubahan UI, komposisi maskot, atau aset visual, baca `context/visual-design-and-mascot.md` sebelum mengedit. Gunakan aturan tersebut sebagai acuan lintas screen mobile.
3. Ikuti alur screen → BLoC/Cubit → use case/repository → remote datasource → ApiClient.
4. Register dependency baru di injection_container.dart dan pastikan lifecycle factory/singleton tepat.
5. Route baru harus terdaftar di AppRouter, mengikuti secure-by-default redirect, dan memiliki loading/error/empty state.
6. Pertahankan responsive layout, accessibility, offline banner/game behavior, auth guard, dan global mini-player/FAB overlay.
7. Gunakan AppConfig untuk environment; jangan membaca dotenv, dart-define, atau URL langsung dari feature.
8. BASE_URL adalah host-only; jangan menambahkan /api/v1 kedua pada datasource.
9. Jangan menaruh secret, token, data kesehatan mental, credential release, atau API key di source/assets/log.

## Validasi

- Perubahan Dart/UI/data: flutter analyze --no-fatal-infos --no-fatal-warnings dan flutter test.
- Jangan menjalankan `flutter build`, Gradle, `xcodebuild`, atau membuat APK/IPA/artifact build secara otomatis setelah mengubah kode, aset, config, platform, maupun workflow. Tunggu permintaan build yang eksplisit dari pengguna.
- Saat build tidak diminta, jangan menjalankannya hanya untuk validasi; sebutkan bahwa build belum dijalankan bila relevan.
- Jika pengguna secara eksplisit meminta build, ikuti target/platform yang diminta. Jika toolchain tidak tersedia atau build gagal, laporkan error sebenarnya dan command yang belum terverifikasi.
- Perubahan API mapping: cek OpenAPI API, web client, dan tests config/parser.
- Sebelum selesai, jalankan git diff --check.

## Generated files dan release

- Jangan mengedit .dart_tool/, build/, atau generated plugin output sebagai solusi feature.
- pubspec.yaml dan pubspec.lock adalah sumber dependency Flutter. package-lock.json bukan workflow package manager aplikasi.
- CI memakai dart-define dan membuat placeholder .env; jangan membutuhkan secret .env pada CI.
- Jangan mengubah application ID, signing, bundle identifier, atau release workflow tanpa dampak yang terdokumentasi.

## Dokumentasi dan koordinasi

- Perbarui README/context ketika route, feature parity, API mapping, config precedence, platform behavior, atau release workflow berubah.
- Mobile hanya member; admin/mitra tetap web.
- Perubahan API wajib dicek terhadap datasource/model mobile dan service/schema web.
- Context harus merangkum keputusan/invariant, bukan menyalin roadmap lama atau seluruh source.

## Data sensitif dan AI

- Perlakukan journal, chat dan context AI, mood, profil, serta billing sebagai data pribadi. Batasi data yang ditampilkan, disimpan, atau dicatat ke kebutuhan fitur dan hak akses member.
- Backend API adalah otoritas untuk autentikasi, role, dan ownership. State persetujuan AI disimpan melalui API, sedangkan mobile menjaga gate/disclaimer chat sesuai alur produk; UI gate bukan kontrol akses server.
- Prompt/model AI, kuota, moderasi, dan kebijakan krisis dimiliki API. Mobile hanya memakai capability member melalui contract; jangan menanam prompt sistem, provider credential, atau akses model langsung ke aplikasi.
- Pertahankan consent/disclaimer chat AI, pilihan privasi journal, perlindungan data lokal, serta state error/fallback yang disediakan API.
- Scope aplikasi hanya member (`user`). Jangan menambahkan endpoint, credential, atau screen privileged admin/moderator/mitra.

## Code review rules

- Flag datasource yang membuat URL tidak sesuai host-only contract.
- Flag route private yang lolos tanpa auth redirect.
- Flag state mutation langsung dari widget yang melewati BLoC/use case.
- Flag penggunaan credential, data journal/chat/mood, atau generated artifact sebagai source perubahan.
- Jangan gunakan ikon UI `Icons.star_*`, `Icons.auto_awesome*`, atau padanan Sparkles/Star sebagai penanda AI generik, aksen dekoratif, pilihan/featured, EXP, atau badge. Pilih ikon sesuai fungsi, misalnya `Icons.chat_bubble_outline_rounded` untuk percakapan, `Icons.calendar_today_rounded` untuk check-in, `Icons.lightbulb_outline_rounded` untuk insight, `Icons.verified_rounded` untuk konten pilihan, serta `Icons.workspace_premium_rounded`/`Icons.emoji_events_rounded` untuk pencapaian. Bintang yang digambar sebagai objek koleksi di dalam artwork game bukan ikon UI dan boleh dipertahankan.
