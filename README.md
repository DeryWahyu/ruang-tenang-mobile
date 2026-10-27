# Ruang Tenang Mobile

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![BLoC](https://img.shields.io/badge/BLoC-State_Management-blue?style=for-the-badge)](https://bloclibrary.dev/)
[![Dio](https://img.shields.io/badge/Dio-Networking-informational?style=for-the-badge)](https://pub.dev/packages/dio)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-brightgreen?style=for-the-badge)](https://flutter.dev/)

Aplikasi mobile-first berbasis **Flutter** untuk platform kesehatan mental **Ruang Tenang**. Aplikasi ini didesain khusus bagi **Member (Mahasiswa & Pengguna Umum)** untuk mendampingi rutinitas *self-care* harian, pelacakan suasana hati, konseling AI interaktif, komunitas suportif, audio relaksasi, serta gamifikasi kebiasaan positif.

---

## Daftar Isi

- [Konteks Ekosistem](#konteks-ekosistem)
- [Fitur Utama Member](#fitur-utama-member)
- [Prasyarat Sistem](#prasyarat-sistem)
- [Mulai Cepat (Quick Start)](#mulai-cepat-quick-start)
  - [Langkah Instalasi](#langkah-instalasi)
  - [Panduan Penentuan BASE_URL](#panduan-penentuan-base_url-sangat-penting)
  - [Menjalankan dengan --dart-define](#menjalankan-dengan---dart-define)
- [Daftar Perintah Verifikasi & Build](#daftar-perintah-verifikasi--build)
- [Konfigurasi Environment](#konfigurasi-environment)
- [Arsitektur & Struktur Direktori](#arsitektur--struktur-direktori)
- [Navigasi & Routing](#navigasi--routing)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [CI/CD & Rilis APK](#cicd--rilis-apk)
- [Keamanan & Kontribusi](#keamanan--kontribusi)

---

## Konteks Ekosistem

Aplikasi mobile ini merupakan salah satu antarmuka klien dalam ekosistem Ruang Tenang:
1. **Backend API (`ruang-tenang-api`)**: Menangani seluruh logika bisnis, database MySQL, pemrosesan AI, dan billing. Aplikasi mobile berkomunikasi langsung dengan API backend.
2. **Frontend Web (`ruang-tenang-web`)**: Menangani dashboard multi-peran (Member, Admin/Moderator, dan Mitra Organisasi).

> [!NOTE]
> Aplikasi mobile ini **hanya ditujukan untuk peran Member**. Fitur panel kontrol Admin, moderasi konten, dan analitik Mitra Organisasi B2B dikelola secara eksklusif melalui platform Web.

---

## Fitur Utama Member

- **Beranda Interaktif**: Ringkasan aktivitas harian, rekomendasi konten, kartu check-in cepat, dan tur panduan fitur (*feature tour*).
- **Self-Care & Jurnal**: Pencatatan emosi harian (*mood tracker*), penulisan jurnal refleksi diri (dukungan status publik atau privat), dan riwayat kalender.
- **AI Mental Companion**: Sesi konseling chat AI dengan persetujuan privasi, masukan suara (*voice input*), dan respons kontekstual berdasarkan histori jurnal.
- **Audio & Musik Relaksasi**: Pemutar musik instrumen berlisensi CC BY 4.0, timer tidur (*sleep timer*), dan kurasi playlist penenang kecemasan.
- **Komunitas & Kisah**: Membaca dan membagikan kisah perjuangan (*stories*), berpartisipasi dalam ruang forum diskusi, dan melihat statistik komunitas.
- **Perjalanan & Gamifikasi**: Peta checkpoint petualangan, tugas harian (*daily quests*), sistem perolehan EXP & level, koleksi lencana (*badges*), papan peringkat (*leaderboard*), serta mini-game offline **Mindful Runner**.
- **Toko Koin & Paket**: Top-up koin dan langganan paket self-care melalui payment gateway Duitku.

---

## Prasyarat Sistem

Sebelum menjalankan proyek, pastikan Anda telah menyiapkan:
- **Flutter SDK**: Versi stable (sesuai Dart SDK `^3.11.4` pada `pubspec.yaml`)
- **Android Studio / Android SDK**: Dengan platform tools dan emulator aktif (rekomendasi API level 33+)
- **Xcode & CocoaPods**: (Khusus macOS) jika ingin melakukan kompilasi dan menjalankan di iOS simulator/device
- **Backend API**: Layanan [ruang-tenang-api](file:///home/alfiang/Projects/ruang-tenang/ruang-tenang-api) sudah berjalan dan dapat dijangkau dari jaringan device/emulator

---

## Mulai Cepat (Quick Start)

### Langkah Instalasi

1. **Unduh Paket Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Salin File Konfigurasi Environment:**
   ```bash
   cp .env.example .env
   ```

3. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---

### Panduan Penentuan `BASE_URL` (Sangat Penting!)

Nilai `BASE_URL` adalah alamat host API **tanpa akhiran `/api/v1`** (klien Dio internal akan menambahkan prefix tersebut secara otomatis). Sesuaikan alamat target dengan lingkungan pengujian Anda:

| Lingkungan Pengujian | Nilai `BASE_URL` yang Tepat | Catatan |
| :--- | :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:8080` | Alamat alias loopback host pada emulator Android standar |
| **iOS Simulator** | `http://localhost:8080` | Simulator iOS berbagi loopback langsung dengan host Mac |
| **Perangkat Fisik (HP Asli)** | `http://<IP-LAN-Komputer>:8080` | Contoh: `http://192.168.1.15:8080`. HP dan laptop wajib berada dalam satu jaringan Wi-Fi yang sama |
| **Tunneling (Ngrok / Cloud)** | `https://xxxx.ngrok-free.app` | Solusi praktis jika ingin menguji di HP fisik tanpa kendala firewall Wi-Fi |
| **Production / Staging** | `https://api.ruang-tenang.site` | Endpoint server produksi HTTPS |

---

### Menjalankan dengan `--dart-define`

Cara terbaik dan paling direkomendasikan untuk beralih environment tanpa perlu mengedit file `.env` secara manual adalah menggunakan argumen `--dart-define`:

```bash
# Menjalankan di Android Emulator
flutter run --dart-define=ENVIRONMENT=development --dart-define=BASE_URL=http://10.0.2.2:8080

# Menjalankan di HP Fisik (ganti dengan IP LAN laptop Anda)
flutter run --dart-define=ENVIRONMENT=development --dart-define=BASE_URL=http://192.168.1.100:8080

# Melakukan kompilasi rilis APK produksi
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.ruang-tenang.site
```

---

## Daftar Perintah Verifikasi & Build

| Perintah | Deskripsi |
| :--- | :--- |
| `flutter pub get` | Mengunduh seluruh dependensi yang didefinisikan di `pubspec.yaml` |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | Melakukan analisis statis kode Dart untuk mendeteksi error/warning |
| `flutter test` | Menjalankan seluruh test suite unit dan widget smoke test |
| `flutter build apk --debug` | Mengompilasi APK mode debug untuk pengujian manual cepat |
| `flutter build apk --release` | Mengompilasi APK mode rilis teroptimasi dengan ukuran file minimal |
| `flutter clean` | Menghapus build cache direktori `build/` dan file konfigurasi sementara |

> [!TIP]
> Setiap modifikasi logika bisnis, datasource API, routing, atau UI minimal wajib melewati `flutter analyze` dan `flutter test` sebelum diajukan ke repository.

---

## Konfigurasi Environment

Aplikasi menerapkan urutan resolusi konfigurasi (*hierarchy order*):
1. **Tertinggi**: Parameter flag `--dart-define` (dipakai oleh CI/CD dan script build release).
2. **Menengah**: Nilai pada file lokal `.env`.
3. **Fallback**: Logika otomatis platform-aware (`10.0.2.2` untuk Android, `localhost` untuk iOS).

| Variabel | Deskripsi | Pilihan / Contoh Nilai |
| :--- | :--- | :--- |
| `ENVIRONMENT` | Lingkungan runtime target | `development`, `staging`, `production` |
| `BASE_URL` | Alamat host server API tanpa `/api/v1` | `http://10.0.2.2:8080`, `https://api.ruang-tenang.site` |

---

## Arsitektur & Struktur Direktori

Proyek ini menerapkan perpaduan **Clean Architecture** dengan pendekatan **Feature-First**:

```text
ruang-tenang-mobile/
├── assets/               # Aset statis: font, ikon, gambar, animasi Lottie
│   └── images/           # Logo, ilustrasi onboarding, mood emoticons, badges
├── lib/
│   ├── core/             # Konfigurasi aplikasi, konstanta, tema, DI (GetIt), klien jaringan (Dio), router
│   ├── data/             # Implementasi data: Remote DataSource, Model JSON serializable, Repository Impl
│   ├── domain/           # Aturan bisnis murni: Entity, kontrak Repository, dan Use Cases
│   └── presentation/     # Antarmuka UI (Screen/Widget) dan State Management (BLoC / Cubit) per modul:
│       ├── auth/         # Login, register WhatsApp, verifikasi OTP, reset password
│       ├── home/         # Beranda mahasiswa, widget check-in, carousel
│       ├── journal/      # Mood tracker & jurnal refleksi
│       ├── chat/         # Chatbot AI konseling & interaksi audio
│       ├── music/        # Pemutar lagu relaksasi instrumental & playlist
│       ├── community/    # Forum diskusi, kisah inspiratif, statistik
│       ├── journey/      # Quest harian, peta petualangan, level, badge, leaderboard
│       └── profile/      # Informasi profil pengguna, paket, transaksi koin
└── test/                 # Pengujian unit logic, mocking datasource, smoke test widget
```

**Alur Data Standar:**  
`Presentation (Screen)` ➔ `BLoC / Cubit` ➔ `Domain (Use Case / Repository Contract)` ➔ `Data (Repository Impl / DataSource)` ➔ `Core (Dio ApiClient)`

---

## Navigasi & Routing

Routing dikelola menggunakan **GoRouter** yang menerapkan prinsip *secure-by-default*:
- **Rute Publik**: Hanya `/splash`, `/onboarding`, dan rute autentikasi (`/login`, `/register`, `/otp`) yang dapat diakses tanpa token.
- **Rute Terproteksi**: Shell navigasi utama terdiri dari 5 tab persistent di dasar layar:
  1. `Home` (`/home`)
  2. `Journal` (`/journal`)
  3. `Chat AI` (`/chat`)
  4. `Music` (`/music`)
  5. `Profile` (`/profile`)
- Halaman tambahan seperti Komunitas, Artikel, Perjalanan Gamifikasi, dan Toko Koin terintegrasi sebagai sub-halaman bertab dengan proteksi sesi akun.

---

## Troubleshooting & FAQ

### 1. `SocketException: OS Error: Connection refused, errno = 111`
- **Penyebab**: Aplikasi tidak dapat menjangkau server backend API.
- **Solusi**:
  - Jika memakai Android Emulator, pastikan `BASE_URL` menggunakan `http://10.0.2.2:8080` (bukan `http://localhost:8080`).
  - Jika memakai HP fisik, pastikan menggunakan alamat IP LAN laptop (misal `http://192.168.1.15:8080`) dan pastikan backend API mengizinkan koneksi dari jaringan luar (bind ke `0.0.0.0` atau firewall laptop mengizinkan port 8080).
  - Pastikan backend `ruang-tenang-api` sudah aktif.

### 2. Gambar aset atau font kustom tidak muncul
Jalankan pembersihan build cache dan muat ulang dependensi:
```bash
flutter clean
flutter pub get
```

### 3. Kendala Pods pada iOS Simulator
Bagi pengguna macOS, lakukan pembaruan pods jika menemui issue native linking:
```bash
cd ios && pod install --repo-update && cd ..
```

---

## CI/CD & Rilis APK

- **Automated Workflow**: Workflow GitHub Actions `.github/workflows/build-apk.yml` dijalankan pada Java 17 dan Flutter stable.
- **Build Pipeline**: Secara otomatis menjalankan `flutter analyze`, membangun APK development dan production menggunakan repository secrets `BASE_URL_DEVELOPMENT` dan `BASE_URL_PRODUCTION`.
- **Rilis Otomatis**: Setiap push ke branch `main`, workflow mengunggah artifact APK terkompilasi dan memperbarui GitHub Release `latest`.

---

## Keamanan & Kontribusi

1. **Jaga Rahasia**: Jangan pernah melakukan commit file `.env`, file keystore Android (`key.jks`), sertifikat iOS (`.p12`), atau credential API pihak ketiga ke Git.
2. **Kepatuhan Role**: Jangan menambahkan navigasi atau antarmuka yang memerlukan hak akses Admin atau Mitra di aplikasi mobile ini; seluruh operasi manajemen tersebut didelegasikan ke web.
3. Pedoman kerja detail untuk agen dan developer tersedia di `AGENTS.md` dan dokumentasi modul di `context/`.
