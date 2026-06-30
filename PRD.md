# PRD — Ruang Tenang Mobile

> **Status:** Draft untuk eksekusi bertahap
> **Versi:** 1.0
> **Terakhir diperbarui:** 2026-06-30
> **Pemilik produk:** Tim Ruang Tenang
> **Pelaksana:** Agen AI (dikerjakan **satu phase per sesi**, lihat [Roadmap Eksekusi per Phase](#7-roadmap-eksekusi-per-phase))

---

## 1. Pendahuluan

### 1.1 Ringkasan Produk

**Ruang Tenang Mobile** adalah aplikasi **Flutter** yang merupakan **versi mobile khusus untuk member (pengguna akhir)** dari ekosistem Ruang Tenang — sebuah platform kesehatan mental & self-care. Aplikasi ini memberikan akses harian yang ringan dan nyaman ke fitur-fitur inti seperti jurnal, pelacakan suasana hati, teman cerita AI, musik relaksasi, latihan pernapasan, artikel, forum komunitas, serta sistem gamifikasi untuk menjaga keterlibatan pengguna.

Aplikasi ini adalah pendamping mobile dari aplikasi web (`ruang-tenang-web`), dengan tujuan **memaksimalkan paritas fitur member** sambil tetap menghormati keterbatasan dan kekhasan UX perangkat mobile.

### 1.2 Tujuan Produk

- Menyediakan pengalaman self-care harian yang **mobile-first**, cepat, dan nyaman.
- Mendekati **paritas fitur** dengan dashboard member di web — semakin dekat semakin baik.
- Menjaga konsistensi data dan pengalaman lintas platform (web ↔ mobile) melalui API yang sama.
- Menyederhanakan kompleksitas: hanya menghadirkan fitur yang relevan untuk member di konteks mobile.

### 1.3 Scope

| Aspek | Keterangan |
|-------|------------|
| **Termasuk** | Seluruh fitur untuk role **member / user biasa** |
| **TIDAK termasuk** | Role **admin** dan **mitra (B2B)** — keduanya **dikecualikan sepenuhnya** dari aplikasi mobile |
| **Platform** | Flutter — Android & iOS (target utama) |

> Aplikasi mobile **tidak** akan memiliki fitur manajemen konten admin (kelola pengguna, artikel, musik, moderasi) maupun fitur mitra (organisasi, langganan B2B, analitik seat, pembayaran B2B). Pengguna dengan role admin/mitra diarahkan menggunakan versi web.

### 1.4 Target Pengguna

- **Member individu** yang memakai layanan Ruang Tenang untuk kesehatan mental & relaksasi sehari-hari.
- Pengguna yang menginginkan akses cepat di perangkat mobile (notifikasi, check-in mood harian, sesi pernapasan singkat, dengarkan musik, menulis jurnal).

### 1.5 Relasi dengan Komponen Lain

| Komponen | Teknologi | Peran |
|----------|-----------|-------|
| `ruang-tenang-mobile` | Flutter (Dart), clean architecture (data/domain/presentation), BLoC/Cubit | **Fokus dokumen ini** — klien mobile khusus member |
| `ruang-tenang-web` | Next.js (TypeScript) | Referensi paritas fitur; mendukung member, admin, dan mitra |
| `ruang-tenang-api` | Go | Backend bersama (sumber kebenaran data & endpoint) |

> **Catatan API:** Bila sebuah fitur target belum memiliki endpoint di `ruang-tenang-api`, endpoint dapat **ditambahkan kemudian**. Ketersediaan API **bukan** penghalang untuk memasukkan fitur ke dalam roadmap.

---

## 2. Fitur Inti (Core)

Fitur-fitur ini adalah tulang punggung aplikasi: selaras dengan web member **dan** sangat cocok untuk UX mobile. Sebagian besar sudah ada dalam bentuk awal di codebase mobile dan perlu dilengkapi/dipoles.

| Fitur | Deskripsi | Paritas Web | Status Mobile Saat Ini |
|-------|-----------|-------------|------------------------|
| **Beranda (Home)** | Dasbor ringkas: sapaan, ringkasan mood, akses cepat fitur, daily task FAB | ✅ Ada (`/dashboard`) | Sudah ada — perlu dilengkapi |
| **Jurnal** | Daftar, buat, edit, hapus, dan detail jurnal pribadi | ✅ Ada (`/dashboard/journal`) | Sudah ada (list/create/detail) — perlu dipoles |
| **Mood Tracker + Check-in Harian** | Pencatatan mood harian, popup check-in 1x/hari, statistik mood | ✅ Ada (`/dashboard/mood-tracker` + MoodCheckinModal) | Sudah ada (tracker, stats, check-in gate) |
| **Teman Cerita AI (Chat)** | Chat AI untuk bercerita, dengan kuota gratis & status premium | ✅ Ada (`/dashboard/chat`) | Sudah ada (list, detail, kuota) |
| **Musik Relaksasi** | Beranda musik, kategori/playlist, detail playlist, pemutar | ✅ Ada (`/dashboard/music`) | Sudah ada (home, playlist detail) |
| **Latihan Pernapasan** | Daftar teknik pernapasan & sesi pernapasan terpandu | ✅ Ada (`/dashboard/breathing`) | Sudah ada (list, session) |
| **Artikel** | Daftar & detail artikel edukasi kesehatan mental | ✅ Ada (`/dashboard/articles`, `/dashboard/reading`) | Sudah ada (list, detail) |
| **Forum Komunitas** | Daftar diskusi & detail thread forum | ✅ Ada (`/dashboard/forum`) | Sudah ada (list, detail) |
| **Kisah Inspiratif (Story)** | Daftar & detail kisah inspiratif dari komunitas | ✅ Ada (`/dashboard/stories`) | Sudah ada (list, detail) |
| **Premium & Billing** | Lihat paket premium, status langganan | ✅ Ada (`/dashboard/billing`) | Sudah ada (premium plans) |
| **Profil & Pengaturan** | Profil, edit profil, ubah kata sandi, pengaturan | ✅ Ada (`/dashboard/profile`, `/dashboard/settings`) | Sudah ada (profile, edit, password, settings) |
| **Autentikasi & Onboarding** | Login, register, lupa/reset password, onboarding, splash | ✅ Ada (`/login`, `/register`, dll.) | Sudah ada |

---

## 3. Fitur Gamifikasi (Selaras Web)

Sesuai keputusan **"samakan dengan gamifikasi web member saja"**, hanya mekanik gamifikasi yang memiliki padanan di web member yang dipertahankan. Mobile saat ini memiliki **jauh lebih banyak** layar gamifikasi daripada web — kelebihannya direkomendasikan untuk dihapus (lihat [Bagian 5](#5-rekomendasi-penghapusan-fitur)).

| Fitur Gamifikasi | Deskripsi | Justifikasi (Paritas Web) |
|------------------|-----------|---------------------------|
| **Game Hub** | Halaman pusat gamifikasi sebagai titik masuk | Hub navigasi untuk fitur gamifikasi yang dipertahankan |
| **Daily Tasks** | Tugas harian + FAB akses cepat | ✅ Web punya `DailyTaskFAB` & daily tasks |
| **Badges (Lencana)** | Koleksi & progres lencana | ✅ Web punya `BadgeComponents`, badge di community |
| **Leaderboard** | Papan peringkat pengguna | ✅ Web punya hall-of-fame / leaderboard |
| **Progress Map (Peta Perjalanan)** | Peta level & progres perjalanan | ✅ Web punya `/dashboard/progress-map` |
| **Rewards (Klaim Hadiah)** | Tukar koin dengan hadiah | ✅ Web punya `/dashboard/rewards` |
| **Guild** | Kelompok komunitas | ✅ Web punya `/dashboard/guilds` |
| **EXP History** | Riwayat perolehan EXP | ✅ Web punya `ExpHistoryModal` |
| **XP Boost** | Status & aktivasi penggali XP | ✅ Web punya `xpBoostService` & status XP boost |

---

## 4. Fitur Tambahan (Gap dari Web)

Fitur berikut **ada di web member** tetapi **belum ada di mobile**. Direkomendasikan untuk ditambahkan agar paritas meningkat.

| Fitur | Deskripsi | Prioritas | Catatan API |
|-------|-----------|-----------|-------------|
| **Top Up Koin** | Isi ulang koin untuk ditukar reward / fitur premium | **P1** | Web: `/dashboard/topup`. Cek endpoint top-up; tambahkan bila belum ada |
| **Statistik Komunitas** | Halaman ringkasan pencapaian komunitas (anggota baru, total XP, hall of impact, diskusi terbaru) | **P1** | Web: `/dashboard/community`. Mungkin perlu endpoint agregat komunitas |
| **Mini Game (Mindful Runner)** | Game relaksasi ringan (lompat & kumpulkan poin), tersedia offline | **P2 (opsional)** | Web: `/dashboard/game` (`MindfulRunnerGame`). **Berat** diimplementasikan ulang di Flutter — pertimbangkan effort vs nilai; bisa ditunda |

> **Catatan:** Mini Game ditandai **opsional** karena membangun ulang game arcade di Flutter membutuhkan effort signifikan (game loop, fisika, aset). Disarankan dikerjakan paling akhir atau ditunda hingga fitur inti stabil.

---

## 5. Rekomendasi Penghapusan Fitur

Karena aplikasi sudah setengah jadi, sebagian fitur yang sudah terlanjur dibuat di mobile **tidak memiliki padanan di web member** dan/atau **kurang cocok untuk UX mobile**. Berikut rekomendasi penghapusan berdasarkan **paritas web (b)** + **kecocokan UX mobile (c)**.

### 5.1 Gamifikasi non-paritas — **Direkomendasikan dihapus**

Layar-layar ini **tidak memiliki halaman padanan di web member** (hanya muncul sebagai entri cache di `ruang-tenang-web/app/sw.ts`, bukan fitur nyata). Menghapusnya menyelaraskan mobile dengan web sesuai keputusan gamifikasi.

| Fitur | Alasan | Dampak (file & route) |
|-------|--------|------------------------|
| **Daily Spin** | Tidak ada di web member | `lib/presentation/gamification/screens/daily_spin_screen.dart`; route `/gamification/spin` di `lib/core/router/app_router.dart`; registrasi di `lib/core/di/injection_container.dart` |
| **Chest / Treasure** | Tidak ada di web member | `lib/presentation/gamification/screens/chest_screen.dart`; route `/gamification/chests`; DI terkait |
| **Streak Society** | Tidak ada di web member | `lib/presentation/gamification/screens/streak_society_screen.dart`; route `/gamification/streak-society`; DI terkait |
| **Timed Challenge** | Tidak ada di web member | `lib/presentation/gamification/screens/timed_challenge_screen.dart`; route `/gamification/timed-challenge`; DI terkait |
| **Friend Quest** | Tidak ada di web member | `lib/presentation/gamification/screens/friend_quest_screen.dart`; route `/gamification/friend-quest`; DI terkait |
| **Weekly League** | Tidak ada di web member | `lib/presentation/gamification/screens/weekly_league_screen.dart`; route `/gamification/weekly-league`; DI terkait |

> Kemungkinan terdapat entity/model/usecase/repository pendukung di `lib/domain/entities/secondary_gamification.dart`, `lib/data/models/secondary_gamification_model.dart`, `lib/data/datasources/remote/secondary_gamification_remote_datasource.dart`, `lib/domain/repositories/secondary_gamification_repository.dart`, dan `lib/presentation/gamification/cubit/secondary_cubits.dart`. Perlu ditinjau saat Phase 0 untuk dibersihkan sejalan dengan penghapusan layar.

### 5.2 Kandidat hapus / tunda — **KEPUTUSAN FINAL** ✅

Status: sudah dikonfirmasi pemilik produk (2026-06-30).

| Fitur | Keputusan | Tindakan yang dilakukan |
|-------|-----------|--------------------------|
| **Explore** | **Gabung ke Home** | Konten grid "semua fitur" dipindahkan ke Home sebagai bottom sheet (tombol "Lihat Semua" pada section Eksplorasi). Layar & route `/explore` dihapus (`lib/presentation/explore/` dihapus, import & route di `app_router.dart` dibersihkan). |
| **Global Search** | **Dipertahankan** | Koreksi: Global Search **ADA** di web member, pada navbar dashboard (`ruang-tenang-web/components/layout/dashboard/TopHeader.tsx` → komponen `GlobalSearch`). Karena selaras web, fitur `/search` di mobile tetap dipertahankan tanpa perubahan. |
| **Wellness (onboarding + plan)** | **Dipertahankan** | Tetap sebagai modul terpisah (`/wellness/onboarding`, `/wellness/plan`). Tidak ada perubahan. |

> **Catatan pencarian per-modul:** rekomendasi awal untuk mengganti Global Search dengan search lokal dibatalkan karena Global Search terbukti ada di web. Search lokal per-modul (Jurnal, Artikel, Forum, Story) tetap berjalan berdampingan sebagai pelengkap.

---

## 5.3 Status Fitur Tambahan (Bagian 4)

| Fitur | Keputusan | Status |
|-------|-----------|--------|
| **Top Up Koin** | Implementasikan | ✅ Selesai (tergabung di layar Premium & Koin, `itemType: topup`) |
| **Statistik Komunitas** | Implementasikan | ✅ Selesai (dibangun end-to-end: `/community`, `GET /community/stats`) |
| **Mini Game (Mindful Runner)** | Implementasikan | ✅ Selesai (offline penuh; `CustomPainter` + `Ticker`, tanpa game engine; route `/game`, high score via SharedPreferences; entry dari Game Hub & Home). |

---

## 6. Struktur Navigasi Usulan

### 6.1 Bottom Navigation (Navigasi Utama)

Pertahankan 5 tab utama yang sudah ada (cocok untuk mobile, fokus pada penggunaan harian):

| Tab | Route | Keterangan |
|-----|-------|------------|
| 🏠 **Home** | `/home` | Beranda + akses cepat + daily task FAB |
| 📖 **Jurnal** | `/journal` | Jurnal harian |
| 💬 **Chat** | `/chat` | Teman Cerita AI (tombol hero di tengah) |
| 🎧 **Musik** | `/music` | Musik relaksasi |
| 👤 **Profil** | `/profile` | Profil & pintu masuk menu sekunder |

### 6.2 Menu Sekunder

Fitur yang tidak masuk bottom nav diakses melalui **Home (kartu/akses cepat)** dan/atau **Profil (daftar menu)**:

- Dari **Home**: Mood, Pernapasan, Artikel, Forum, Kisah Inspiratif, Game Hub (gamifikasi), Statistik Komunitas.
- Dari **Profil**: Edit Profil, Ubah Kata Sandi, Pengaturan, Premium & Billing, Top Up Koin, Riwayat EXP, Logout.
- Dari **Game Hub**: Daily Tasks, Badges, Leaderboard, Progress Map, Rewards, Guild, XP Boost.

---

## 7. Roadmap Eksekusi per Phase

> **PENTING UNTUK PELAKSANA AI:** Kerjakan **satu phase per sesi**. Jangan mencoba mengimplementasikan semua phase sekaligus. Selesaikan, verifikasi (build & jalankan), lalu lanjut ke phase berikutnya. Setiap phase dirancang agar berukuran wajar untuk satu sesi kerja.

### Phase 0 — Pembersihan (Cleanup)

- **Tujuan:** Menyelaraskan mobile dengan web dengan menghapus fitur non-paritas, sebelum membangun di atas fondasi yang bersih.
- **Lingkup:**
  - Hapus layar gamifikasi non-paritas: `daily_spin_screen.dart`, `chest_screen.dart`, `streak_society_screen.dart`, `timed_challenge_screen.dart`, `friend_quest_screen.dart`, `weekly_league_screen.dart`.
  - Bersihkan route terkait di `lib/core/router/app_router.dart` (`/gamification/spin`, `/chests`, `/streak-society`, `/timed-challenge`, `/friend-quest`, `/weekly-league`).
  - Bersihkan registrasi terkait di `lib/core/di/injection_container.dart`.
  - Tinjau & bersihkan kode pendukung `secondary_gamification*` (entity, model, datasource, repository, cubit) bila hanya dipakai fitur yang dihapus.
  - Update tautan/referensi di `game_hub_screen.dart` agar tidak menunjuk layar yang dihapus.
  - **Tunggu keputusan user** untuk Explore / Global Search / Wellness (Bagian 5.2). Jika user menyetujui, hapus/gabung juga di phase ini.
- **Dependensi:** Tidak ada (phase pertama).
- **Kriteria Selesai:** Aplikasi tetap `flutter build` & `flutter analyze` bersih tanpa referensi rusak; tidak ada route/menu yang menunjuk layar terhapus; Game Hub hanya menampilkan fitur gamifikasi yang dipertahankan.

### Phase 1 — Fondasi Navigasi Inti

- **Tujuan:** Memastikan kerangka navigasi & autentikasi solid sebagai fondasi.
- **Lingkup:** Bottom nav (Home, Jurnal, Chat, Musik, Profil) di `main_layout.dart`; alur splash → onboarding → auth → home di `app_router.dart`; login, register, lupa/reset password; guard rute privat.
- **Dependensi:** Phase 0.
- **Kriteria Selesai:** Pengguna dapat onboarding, login/register, dan berpindah antar 5 tab utama dengan mulus; guard rute berfungsi (pengguna belum login diarahkan ke login/onboarding).

### Phase 2 — Self-Care Inti

- **Tujuan:** Menghadirkan fitur self-care harian utama.
- **Lingkup:** Mood Tracker + check-in harian (gate) + statistik; Latihan Pernapasan (list + sesi); Jurnal (list, create, edit, detail, hapus).
- **Dependensi:** Phase 1.
- **Kriteria Selesai:** Pengguna dapat mencatat mood harian, menjalankan sesi pernapasan, serta membuat/membaca/mengubah/menghapus jurnal; data tersinkron dengan API.

### Phase 3 — Konten

- **Tujuan:** Menghadirkan konten konsumsi (baca & dengar).
- **Lingkup:** Artikel (list + detail); Kisah Inspiratif/Story (list + detail); Musik (home, kategori/playlist, detail playlist, pemutar).
- **Dependensi:** Phase 1.
- **Kriteria Selesai:** Pengguna dapat menelusuri & membaca artikel dan kisah, serta memutar musik/playlist.

### Phase 4 — Chat AI & Monetisasi

- **Tujuan:** Menghadirkan fitur unggulan (chat AI) dan jalur monetisasi.
- **Lingkup:** Teman Cerita AI (list sesi, detail, kuota gratis & status premium); Premium & Billing (paket, status langganan); **Top Up Koin** (fitur baru — gap dari web).
- **Dependensi:** Phase 1.
- **Kriteria Selesai:** Pengguna dapat berchat dengan AI sesuai kuota, melihat paket premium, dan melakukan top up koin (atau melihat alur top up jika endpoint belum tersedia — tambahkan kebutuhan API).

### Phase 5 — Komunitas

- **Tujuan:** Menghadirkan fitur sosial/komunitas.
- **Lingkup:** Forum (list + detail), Guild, **Statistik Komunitas** (fitur baru — gap dari web).
- **Dependensi:** Phase 1.
- **Kriteria Selesai:** Pengguna dapat membuka forum & guild serta melihat halaman statistik komunitas.

### Phase 6 — Gamifikasi Selaras Web

- **Tujuan:** Menghadirkan gamifikasi yang dipertahankan (selaras web).
- **Lingkup:** Game Hub, Daily Tasks, Badges, Leaderboard, Progress Map, Rewards, EXP History, XP Boost.
- **Dependensi:** Phase 0 (pembersihan gamifikasi) & Phase 1.
- **Kriteria Selesai:** Seluruh fitur gamifikasi yang dipertahankan berfungsi dan dapat diakses dari Game Hub; tidak ada sisa fitur non-paritas.

### Phase 7 — Pelengkap & Polish

- **Tujuan:** Menyempurnakan & merapikan.
- **Lingkup:** Profil/Settings/Edit Profil/Ubah Kata Sandi; **(opsional)** Mini Game / Mindful Runner; pemenuhan kebutuhan non-fungsional (offline, performa, aksesibilitas — lihat Bagian 8).
- **Dependensi:** Semua phase sebelumnya.
- **Kriteria Selesai:** Pengaturan akun lengkap; aplikasi terasa halus & konsisten; (jika dikerjakan) mini game dapat dimainkan; checklist non-fungsional terpenuhi.

---

## 8. Kebutuhan Non-Fungsional

| Aspek | Target |
|-------|--------|
| **Offline-friendly** | Fitur tertentu (mis. jurnal draft, mini game, konten yang sudah dimuat) sebaiknya tetap berfungsi/terbaca saat offline; sinkronisasi saat kembali online |
| **Performa** | Waktu muat layar cepat, animasi 60fps, hindari rebuild berlebih; lazy-load daftar panjang |
| **Aksesibilitas** | Dukungan ukuran teks dinamis, kontras warna memadai, label semantik untuk pembaca layar |
| **Konsistensi Desain** | Selaras dengan bahasa visual web (warna, ikon, tone) menggunakan tema di `lib/core/theme/` |
| **Keamanan** | Token disimpan aman; rute privat terlindungi; tidak menampilkan fitur admin/mitra |

---

## 9. Catatan untuk Pelaksana AI

1. **Satu phase per sesi.** Jangan menggabungkan banyak phase dalam satu pengerjaan. Selesaikan dan verifikasi sebelum lanjut.
2. **Verifikasi tiap phase:** jalankan `flutter analyze` dan `flutter build` (atau jalankan di emulator) sebelum menandai phase selesai. Perbaiki error sebelum lanjut.
3. **Hormati arsitektur:** ikuti pola clean architecture yang ada (`data` / `domain` / `presentation`) dan state management BLoC/Cubit. Jangan memperkenalkan pola baru tanpa alasan.
4. **API belum ada?** Bila endpoint belum tersedia di `ruang-tenang-api`, dokumentasikan kebutuhan endpoint dan, bila perlu, tambahkan di sisi API — ketersediaan API bukan penghalang.
5. **Member-only:** Jangan pernah menambahkan fitur admin atau mitra ke aplikasi mobile.
6. **Phase 0 menunggu keputusan user** terkait Explore / Global Search / Wellness (Bagian 5.2) sebelum penghapusan dilakukan.
7. **Referensi paritas:** gunakan `ruang-tenang-web` (khususnya `components/layout/dashboard/nav-config.ts` dan folder `app/dashboard/*`) sebagai acuan fitur & perilaku member.

---

## Lampiran A — Ringkasan Keputusan Produk

| Pertanyaan | Keputusan |
|------------|-----------|
| Cakupan fitur mobile vs web | Maksimalkan paritas dengan web member; AI menyeleksi fitur yang layak di mobile |
| Sikap terhadap gamifikasi | Samakan dengan gamifikasi web member saja |
| Basis keputusan keep/remove | Paritas dengan web + kecocokan UX mobile (ketersediaan API bukan penghalang) |
| Role yang didukung | **Member saja** — admin & mitra dikecualikan |
