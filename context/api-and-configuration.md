# API dan Configuration
## URL

AppConfig.baseUrl adalah host tanpa /api/v1. AppConfig.apiBaseUrl menambahkan prefix tersebut. Datasource harus memakai apiBaseUrl atau ApiClient, bukan merangkai prefix manual.

Priority: dart-define, lalu .env, lalu fallback localhost platform-aware. ENVIRONMENT menentukan debug/strict SSL. AppEnvironment hanya facade backward-compatible.

## Local targets

Android emulator biasanya memakai 10.0.2.2. iOS simulator memakai localhost. Physical device membutuhkan IP LAN host API; nilai fallback lokal di AppConfig adalah developer-specific dan harus disesuaikan sebelum dipakai tim lain.

CI membuat .env kosong karena flutter_dotenv membutuhkan asset, lalu menyuntikkan BASE_URL lewat dart-define. Jangan menaruh URL production secret atau credential dalam .env ter-track.

## Auth dan storage

ApiClient/interceptor menangani authorization, error, dan response. Token/credential disimpan melalui secure storage sesuai storage keys. Shared preferences hanya untuk preference/cache non-secret seperti onboarding atau high score.

## Contract mapping

Model Dart dan datasource harus mengikuti route/DTO OpenAPI API. Saat response berubah, cek nullability, pagination, timestamp, upload/media URL, error envelope, entitlement, dan role. Mobile hanya memanggil capability member.

## Upload dan media

Gunakan helper media URL/API repository yang ada. Jangan menganggap path media sudah absolute; backend dapat mengembalikan relative upload/storage path.
