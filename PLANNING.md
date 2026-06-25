# Ruang Tenang Mobile - Planning Document

> **Platform**: Flutter (Dart SDK ^3.11.4)
> **Target**: Android & iOS
> **Backend**: Ruang Tenang API (Go/Gin) — `BASE_URL/api/v1`
> **Referensi Desain**: Ruang Tenang Web (Next.js 15 / React 19)

---

## Daftar Isi

1. [Gambaran Umum Sistem](#1-gambaran-umum-sistem)
2. [Arsitektur Aplikasi Mobile](#2-arsitektur-aplikasi-mobile)
3. [Design System](#3-design-system)
4. [Struktur Folder](#4-struktur-folder)
5. [Fitur & Halaman](#5-fitur--halaman)
6. [API Integration](#6-api-integration)
7. [State Management](#7-state-management)
8. [Navigasi & Routing](#8-navigasi--routing)
9. [Dependency / Package](#9-dependency--package)
10. [Fase Pengembangan](#10-fase-pengembangan)

---

## 1. Gambaran Umum Sistem

**Ruang Tenang** adalah platform kesehatan mental yang menyediakan:

- **AI Chatbot** — Konseling berbasis Gemini AI, dengan session & folder management
- **Journal** — Catatan harian dengan rich text editor, AI insights, export
- **Mood Tracker** — Pelacakan suasana hati harian dengan statistik & analitik
- **Breathing Exercise** — Teknik pernapasan terpandu dengan timer & statistik
- **Music/Playlist** — Pemutar musik relaksasi dengan playlist management
- **Community Forum** — Forum diskusi dengan kategori, voting, accepted answers
- **Inspiring Stories** — Cerita inspiratif dari pengguna dengan komentar & heart
- **Article/Reading** — Artikel edukasi kesehatan mental
- **Gamification** — XP, Level, Badge, Daily Tasks, Guild, Leaderboard, Progress Map, Mystery Chest, Daily Spin, Streak, Timed Challenge
- **Billing/Premium** — Langganan premium via Midtrans, top-up gold coins
- **Notification** — Push notification & in-app notification
- **B2B (Mitra)** — Dashboard organisasi (khusus role mitra)
- **Admin** — Dashboard admin (khusus role admin)

### Roles

| Role | Deskripsi |
|------|-----------|
| `user` | Pengguna umum — akses semua fitur utama |
| `admin` | Administrator — moderasi, manajemen konten |
| `mitra` | Partner B2B — manajemen organisasi & anggota |

### API Response Format

```json
// Success
{ "success": true, "message": "...", "data": { ... } }

// Success (Paginated)
{ "success": true, "data": [...], "page": 1, "limit": 10, "total_items": 100, "total_pages": 10 }

// Error
{ "success": false, "error": "...", "code": "ERR_VALIDATION" }

// Validation Error
{ "success": false, "code": "ERR_VALIDATION", "error": "Validation failed", "details": [{ "field": "email", "message": "..." }] }
```

---

## 2. Arsitektur Aplikasi Mobile

### Pattern: Clean Architecture + BLoC

```
lib/
├── core/           → Foundation layer (theme, constants, network, utils)
├── data/           → Data layer (models, repositories, data sources)
├── domain/         → Domain layer (entities, use cases, repository interfaces)
├── presentation/   → UI layer (screens, widgets, blocs)
└── main.dart       → Entry point
```

### Prinsip Arsitektur

1. **Separation of Concerns** — Setiap layer punya tanggung jawab masing-masing
2. **Dependency Inversion** — Layer atas tidak bergantung langsung ke layer bawah
3. **Single Source of Truth** — State dikelola terpusat via BLoC
4. **Offline-First** — Data penting di-cache lokal (journal, mood) untuk akses offline
5. **Reusable Components** — Widget dibuat modular dan bisa dipakai ulang

---

## 3. Design System

### 3.1 Warna (Color Palette)

Diambil langsung dari CSS variables di `ruang-tenang-web/app/globals.css`:

#### Warna Utama (Primary Red Theme)

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `primary` | `#EF4444` | Tombol utama, link, aksen, ring focus |
| `primaryForeground` | `#FFFFFF` | Teks di atas warna primary |
| `secondary` | `#FEE2E2` | Background secondary, badge ringan |
| `secondaryForeground` | `#1F2937` | Teks di atas secondary |
| `background` | `#F9FAFB` | Background halaman/scaffold |
| `foreground` | `#111827` | Teks utama body |
| `card` | `#FFFFFF` | Background card/container |
| `cardForeground` | `#111827` | Teks di dalam card |
| `muted` | `#F3F4F6` | Background elemen non-aktif |
| `mutedForeground` | `#6B7280` | Teks secondary / placeholder |
| `destructive` | `#DC2626` | Error, delete, destructive action |
| `destructiveForeground` | `#FFFFFF` | Teks di atas destructive |
| `border` | `#E5E7EB` | Border card, divider |
| `input` | `#E5E7EB` | Border input field |
| `ring` | `#EF4444` | Focus ring |

#### Red Palette (Gradasi)

| Token | Hex |
|-------|-----|
| `red50` | `#FEF2F2` |
| `red100` | `#FEE2E2` |
| `red200` | `#FECACA` |
| `red300` | `#FCA5A5` |
| `red400` | `#F87171` |
| `red500` | `#EF4444` |
| `red600` | `#DC2626` |
| `red700` | `#B91C1C` |

#### Accent (Orange/Amber — untuk gamification & highlight)

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `accent` | `#F97316` | Aksen gamification |
| `accentHover` | `#EA580C` | Hover state accent |
| `accentLight` | `#FFEDD5` | Background ringan accent |
| `accentSoft` | `#FFF7ED` | Background sangat ringan |
| `accentDark` | `#C2410C` | Teks gelap di konteks accent |
| `accentText` | `#9A3412` | Teks di atas accent background |
| `accentBorder` | `#FED7AA` | Border aksen |

#### Warna Tambahan (Kontekstual)

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `fabGradientFrom` | `#FB923C` | Floating Action Button gradient start |
| `fabGradientVia` | `#F59E0B` | FAB gradient middle |
| `fabGradientTo` | `#FACC15` | FAB gradient end |
| `notification` | `#EF4444` | Badge notifikasi |
| `storyFrom` | `#FFFBEB` | Background cerita gradient start |
| `storyTo` | `#FFF7ED` | Background cerita gradient end |
| `storyBorder` | `#FDE68A` | Border cerita |
| `storyIconBg` | `#FEF3C7` | Icon background cerita |
| `storyIcon` | `#D97706` | Warna icon cerita |
| `storyHeading` | `#92400E` | Heading cerita |

> **Catatan**: Web juga mendukung alternate themes (Ocean Calm/Blue, Forest Zen/Green, Sunset Warmth/Orange). Di mobile, kita mulai dengan **Default Red Theme** terlebih dahulu. Dukungan multi-theme bisa ditambahkan di fase berikutnya.

### 3.2 Tipografi (Fonts)

Sesuai dengan web yang menggunakan Google Fonts:

| Peran | Font Family | Penggunaan |
|-------|-------------|------------|
| **Sans (Body)** | `Plus Jakarta Sans` | Teks body, paragraf, label, input |
| **Display (Heading)** | `Nunito` | Judul halaman, heading section, display text |

#### Skala Ukuran Font

| Nama | Size | Weight | Penggunaan |
|------|------|--------|------------|
| `displayLarge` | 32sp | Bold (700) | Judul halaman utama |
| `displayMedium` | 28sp | Bold (700) | Sub-judul besar |
| `displaySmall` | 24sp | SemiBold (600) | Section heading |
| `headlineLarge` | 22sp | SemiBold (600) | Card title besar |
| `headlineMedium` | 20sp | SemiBold (600) | Card title |
| `headlineSmall` | 18sp | Medium (500) | Sub-heading |
| `titleLarge` | 17sp | SemiBold (600) | AppBar title |
| `titleMedium` | 15sp | Medium (500) | List item title |
| `titleSmall` | 13sp | Medium (500) | Label kecil bold |
| `bodyLarge` | 16sp | Regular (400) | Body text utama |
| `bodyMedium` | 14sp | Regular (400) | Body text standar |
| `bodySmall` | 12sp | Regular (400) | Caption, helper text |
| `labelLarge` | 14sp | SemiBold (600) | Button text |
| `labelMedium` | 12sp | Medium (500) | Tab label, chip |
| `labelSmall` | 10sp | Medium (500) | Badge text, hint |

> Font **Display** (heading) menggunakan `Nunito`, semua teks lainnya menggunakan `Plus Jakarta Sans`.

### 3.3 Spacing & Sizing

| Token | Value | Penggunaan |
|-------|-------|------------|
| `xs` | 4dp | Gap sangat kecil |
| `sm` | 8dp | Padding internal kecil |
| `md` | 12dp | Gap antar elemen |
| `base` | 16dp | Padding standar, margin |
| `lg` | 20dp | Spacing section |
| `xl` | 24dp | Padding container |
| `2xl` | 32dp | Gap antar section besar |
| `3xl` | 48dp | Top margin halaman |

### 3.4 Border Radius

| Token | Value | Penggunaan |
|-------|-------|------------|
| `sm` | 8dp | Input, chip kecil |
| `md` | 10dp | Card kecil |
| `lg` | 12dp | Card standar, button |
| `xl` | 16dp | Card besar, modal |
| `2xl` | 24dp | Bottom sheet, rounded container |
| `full` | 999dp | Avatar, pill shape, badge |

### 3.5 Shadow / Elevation

| Token | Elevation | Penggunaan |
|-------|-----------|------------|
| `sm` | 1dp | Card dasar |
| `md` | 3dp | Card terangkat, dropdown |
| `lg` | 6dp | Modal, floating element |

### 3.6 Komponen UI

#### Button Variants

```
┌─────────────────────────────────────────────────────┐
│  DEFAULT (Primary)                                  │
│  Background: #EF4444 | Text: #FFFFFF               │
│  Border Radius: 12dp | Padding: H16 V12            │
│  Shadow: sm                                         │
├─────────────────────────────────────────────────────┤
│  SECONDARY                                          │
│  Background: #FEE2E2 | Text: #1F2937               │
│  Border Radius: 12dp | Padding: H16 V12            │
├─────────────────────────────────────────────────────┤
│  OUTLINE                                            │
│  Background: transparent | Text: #111827            │
│  Border: 1dp #E5E7EB | Border Radius: 12dp         │
├─────────────────────────────────────────────────────┤
│  GHOST                                              │
│  Background: transparent | Text: #111827            │
│  Hover/Press: bg #FEE2E2                            │
├─────────────────────────────────────────────────────┤
│  DESTRUCTIVE                                        │
│  Background: #DC2626 | Text: #FFFFFF                │
│  Border Radius: 12dp                                │
├─────────────────────────────────────────────────────┤
│  TEXT / LINK                                        │
│  Background: transparent | Text: #EF4444            │
│  Underline on press                                 │
└─────────────────────────────────────────────────────┘

Button Sizes:
  sm  → Height: 36dp | Padding: H12 V8  | Font: 12sp
  md  → Height: 40dp | Padding: H16 V10 | Font: 14sp
  lg  → Height: 44dp | Padding: H32 V12 | Font: 14sp
  icon → 40dp x 40dp square
```

#### Card

```
┌──────────────────────────────────────┐
│  Background: #FFFFFF                 │
│  Border: 1dp #E5E7EB                │
│  Border Radius: 16dp                │
│  Shadow: sm (elevation 1)           │
│  Padding: 16dp                      │
│                                      │
│  CardHeader: padding-bottom 12dp    │
│  CardContent: padding-top 0         │
└──────────────────────────────────────┘
```

#### Input Field

```
┌──────────────────────────────────────┐
│  Height: 48dp                        │
│  Background: #FFFFFF                 │
│  Border: 1dp #E5E7EB (gray-300)     │
│  Border Radius: 12dp                │
│  Padding: H12 V14                   │
│  Font: 14sp Regular                 │
│  Placeholder: #6B7280               │
│                                      │
│  Focus State:                        │
│    Border: 2dp #EF4444              │
│    Ring shadow: #EF4444 (opacity)   │
│                                      │
│  Error State:                        │
│    Border: 2dp #DC2626              │
│    Helper text: #DC2626, 12sp       │
└──────────────────────────────────────┘
```

#### Bottom Navigation Bar

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│   🏠        📖        💬        🎵        👤            │
│  Home     Journal    Chat     Music    Profile           │
│                                                          │
│  Active:   Icon #EF4444, Label #EF4444                  │
│  Inactive: Icon #6B7280, Label #6B7280                  │
│  Background: #FFFFFF                                     │
│  Border Top: 1dp #E5E7EB                                │
│  Height: 64dp                                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

#### Floating Action Button (Gamification / Daily Tasks)

```
┌──────────────────────────────────┐
│  Shape: Circle (56dp)            │
│  Gradient: #FB923C → #F59E0B →  │
│            #FACC15               │
│  Shadow: lg (elevation 6)       │
│  Icon: #FFFFFF                   │
│  Position: Bottom Right          │
│  Margin Bottom: 80dp (above nav)│
└──────────────────────────────────┘
```

---

## 4. Struktur Folder

```
lib/
├── main.dart
├── app.dart                           # MaterialApp, theme, router setup
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # Base URL, endpoint paths
│   │   ├── app_constants.dart         # App name, version, keys
│   │   └── storage_keys.dart          # SharedPreferences / Hive keys
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData utama (light)
│   │   ├── app_colors.dart            # Semua warna (sesuai design system)
│   │   ├── app_typography.dart        # TextTheme, font config
│   │   └── app_dimensions.dart        # Spacing, radius, elevation
│   ├── network/
│   │   ├── api_client.dart            # Dio HTTP client setup
│   │   ├── api_interceptors.dart      # Auth token, error, logging interceptors
│   │   ├── api_response.dart          # Generic response wrapper
│   │   └── api_exceptions.dart        # Custom exception classes
│   ├── utils/
│   │   ├── date_utils.dart            # Format tanggal Indonesia
│   │   ├── validators.dart            # Form validation helpers
│   │   ├── extensions.dart            # Dart extensions
│   │   └── helpers.dart               # Utility functions
│   ├── di/
│   │   └── injection_container.dart   # GetIt dependency injection
│   └── router/
│       └── app_router.dart            # GoRouter configuration
│
├── data/
│   ├── models/                        # JSON serializable models
│   │   ├── user_model.dart
│   │   ├── article_model.dart
│   │   ├── chat_session_model.dart
│   │   ├── chat_message_model.dart
│   │   ├── journal_model.dart
│   │   ├── mood_model.dart
│   │   ├── song_model.dart
│   │   ├── playlist_model.dart
│   │   ├── forum_model.dart
│   │   ├── post_model.dart
│   │   ├── story_model.dart
│   │   ├── breathing_model.dart
│   │   ├── badge_model.dart
│   │   ├── daily_task_model.dart
│   │   ├── guild_model.dart
│   │   ├── notification_model.dart
│   │   ├── billing_model.dart
│   │   └── pagination_model.dart
│   ├── datasources/
│   │   ├── remote/                    # API data sources
│   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── chat_remote_datasource.dart
│   │   │   ├── journal_remote_datasource.dart
│   │   │   ├── mood_remote_datasource.dart
│   │   │   ├── music_remote_datasource.dart
│   │   │   ├── forum_remote_datasource.dart
│   │   │   ├── story_remote_datasource.dart
│   │   │   ├── breathing_remote_datasource.dart
│   │   │   ├── gamification_remote_datasource.dart
│   │   │   ├── article_remote_datasource.dart
│   │   │   ├── notification_remote_datasource.dart
│   │   │   └── billing_remote_datasource.dart
│   │   └── local/                     # Local cache (Hive / SQLite)
│   │       ├── journal_local_datasource.dart
│   │       ├── mood_local_datasource.dart
│   │       └── cache_manager.dart
│   └── repositories/                  # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── chat_repository_impl.dart
│       ├── journal_repository_impl.dart
│       ├── mood_repository_impl.dart
│       ├── music_repository_impl.dart
│       ├── forum_repository_impl.dart
│       ├── story_repository_impl.dart
│       ├── breathing_repository_impl.dart
│       ├── gamification_repository_impl.dart
│       ├── article_repository_impl.dart
│       ├── notification_repository_impl.dart
│       └── billing_repository_impl.dart
│
├── domain/
│   ├── entities/                      # Pure Dart entities
│   │   ├── user.dart
│   │   ├── article.dart
│   │   ├── chat_session.dart
│   │   ├── journal.dart
│   │   ├── mood.dart
│   │   ├── song.dart
│   │   ├── forum.dart
│   │   ├── story.dart
│   │   ├── breathing.dart
│   │   ├── badge.dart
│   │   └── notification.dart
│   ├── repositories/                  # Abstract repository interfaces
│   │   ├── auth_repository.dart
│   │   ├── chat_repository.dart
│   │   ├── journal_repository.dart
│   │   ├── mood_repository.dart
│   │   ├── music_repository.dart
│   │   ├── forum_repository.dart
│   │   ├── story_repository.dart
│   │   ├── breathing_repository.dart
│   │   ├── gamification_repository.dart
│   │   ├── article_repository.dart
│   │   ├── notification_repository.dart
│   │   └── billing_repository.dart
│   └── usecases/                      # Business logic use cases
│       ├── auth/
│       ├── chat/
│       ├── journal/
│       ├── mood/
│       ├── music/
│       ├── forum/
│       ├── story/
│       ├── breathing/
│       ├── gamification/
│       ├── article/
│       ├── notification/
│       └── billing/
│
├── presentation/
│   ├── common/                        # Shared/reusable widgets
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_input.dart
│   │   │   ├── app_dialog.dart
│   │   │   ├── app_bottom_sheet.dart
│   │   │   ├── app_loading.dart
│   │   │   ├── app_empty_state.dart
│   │   │   ├── app_error_widget.dart
│   │   │   ├── app_avatar.dart
│   │   │   ├── app_badge.dart
│   │   │   ├── app_chip.dart
│   │   │   ├── app_search_bar.dart
│   │   │   ├── app_skeleton.dart
│   │   │   └── mood_emoji.dart
│   │   └── layouts/
│   │       ├── main_layout.dart        # Scaffold + BottomNav
│   │       └── auth_layout.dart        # Layout halaman auth
│   │
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       ├── forgot_password_screen.dart
│   │       └── reset_password_screen.dart
│   │
│   ├── home/
│   │   ├── bloc/
│   │   └── screens/
│   │       └── home_screen.dart
│   │
│   ├── chat/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_detail_screen.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       ├── chat_input.dart
│   │       └── chat_session_tile.dart
│   │
│   ├── journal/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── journal_list_screen.dart
│   │   │   ├── journal_create_screen.dart
│   │   │   └── journal_detail_screen.dart
│   │   └── widgets/
│   │
│   ├── mood/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── mood_tracker_screen.dart
│   │   │   └── mood_stats_screen.dart
│   │   └── widgets/
│   │       └── mood_picker.dart
│   │
│   ├── music/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── music_home_screen.dart
│   │   │   ├── playlist_detail_screen.dart
│   │   │   └── music_player_screen.dart
│   │   └── widgets/
│   │       ├── mini_player.dart
│   │       └── song_tile.dart
│   │
│   ├── breathing/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── breathing_home_screen.dart
│   │   │   └── breathing_session_screen.dart
│   │   └── widgets/
│   │       └── breathing_animation.dart
│   │
│   ├── forum/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── forum_list_screen.dart
│   │   │   ├── forum_detail_screen.dart
│   │   │   └── forum_create_screen.dart
│   │   └── widgets/
│   │       ├── forum_card.dart
│   │       └── post_card.dart
│   │
│   ├── story/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── story_list_screen.dart
│   │   │   ├── story_detail_screen.dart
│   │   │   └── story_create_screen.dart
│   │   └── widgets/
│   │
│   ├── article/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── article_list_screen.dart
│   │   │   └── article_detail_screen.dart
│   │   └── widgets/
│   │
│   ├── gamification/
│   │   ├── bloc/
│   │   ├── screens/
│   │   │   ├── game_hub_screen.dart
│   │   │   ├── badges_screen.dart
│   │   │   ├── leaderboard_screen.dart
│   │   │   ├── daily_tasks_screen.dart
│   │   │   ├── progress_map_screen.dart
│   │   │   ├── guild_screen.dart
│   │   │   ├── daily_spin_screen.dart
│   │   │   └── rewards_shop_screen.dart
│   │   └── widgets/
│   │       ├── xp_bar.dart
│   │       ├── level_badge.dart
│   │       ├── streak_card.dart
│   │       └── daily_task_fab.dart
│   │
│   ├── notification/
│   │   ├── bloc/
│   │   └── screens/
│   │       └── notification_screen.dart
│   │
│   ├── profile/
│   │   ├── bloc/
│   │   └── screens/
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   └── billing/
│       ├── bloc/
│       └── screens/
│           ├── premium_screen.dart
│           └── transaction_history_screen.dart
│
└── assets/
    ├── fonts/
    │   ├── PlusJakartaSans/           # .ttf files
    │   └── Nunito/                    # .ttf files
    ├── images/
    │   ├── logo-full.webp
    │   ├── moods/                     # Emoji mood icons (1-happy.png, etc.)
    │   ├── illustrations/             # Vectors & illustrations
    │   └── onboarding/
    └── icons/                         # Custom SVG icons
```

---

## 5. Fitur & Halaman

### 5.1 Onboarding / Splash

| Screen | Deskripsi |
|--------|-----------|
| `SplashScreen` | Logo Ruang Tenang + loading, cek token → redirect |
| `OnboardingScreen` | 3 slide pengenalan fitur (hanya ditampilkan sekali) |

#### Desain Splash Screen

```
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│       ┌─────────────┐      │
│       │  LOGO        │      │
│       │  Ruang Tenang│      │
│       └─────────────┘      │
│                             │
│       ● ● ● (loading)      │
│                             │
│   bg: #FFFFFF               │
│   logo color: #EF4444       │
│                             │
└─────────────────────────────┘
```

### 5.2 Autentikasi

| Screen | Deskripsi | API Endpoint |
|--------|-----------|--------------|
| `LoginScreen` | Email + Password login | `POST /auth/login` |
| `RegisterScreen` | Daftar akun baru | `POST /auth/register` |
| `ForgotPasswordScreen` | Reset via email | `POST /auth/forgot-password` |
| `ResetPasswordScreen` | Input password baru | `POST /auth/reset-password` |

#### Desain Login Screen

```
┌─────────────────────────────┐
│                             │
│  bg: #F9FAFB                │
│                             │
│       ┌─────────────┐      │
│       │    LOGO      │      │
│       └─────────────┘      │
│                             │
│  ┌───────────────────────┐  │
│  │  Selamat Datang       │  │ ← Nunito Bold 24sp #111827
│  │  Masuk ke akunmu      │  │ ← Plus Jakarta Sans 14sp #6B7280
│  │                       │  │
│  │  ┌─────────────────┐  │  │
│  │  │ Email           │  │  │ ← Input field
│  │  └─────────────────┘  │  │
│  │  ┌─────────────────┐  │  │
│  │  │ Password      👁 │  │  │ ← Input with toggle
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Lupa Password?       │  │ ← #EF4444 link
│  │                       │  │
│  │  ┌─────────────────┐  │  │
│  │  │     MASUK       │  │  │ ← Primary button #EF4444
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Belum punya akun?    │  │
│  │  Daftar              │  │ ← #EF4444 link
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

### 5.3 Home / Dashboard

| Screen | Deskripsi |
|--------|-----------|
| `HomeScreen` | Dashboard utama dengan ringkasan fitur |

#### Desain Home Screen

```
┌─────────────────────────────┐
│  ┌─ AppBar ──────────────┐  │
│  │ 👤 Hi, Nama    🔔(3)  │  │ ← Avatar + notif count
│  └───────────────────────┘  │
│                             │
│  ┌── Mood Check Card ────┐  │
│  │ Bagaimana perasaanmu   │  │
│  │ hari ini?              │  │
│  │ 😊 😐 😢 😡 😰        │  │ ← Mood emoji row
│  └───────────────────────┘  │
│                             │
│  ┌── XP Progress ────────┐  │
│  │ Level 5 ██████░░ 650XP │  │ ← Level bar
│  │ 🔥 Streak: 7 hari     │  │
│  └───────────────────────┘  │
│                             │
│  ┌── Quick Actions ──────┐  │
│  │ 📝 Journal    💬 Chat │  │
│  │ 🫁 Breathing  🎵 Music│  │
│  └───────────────────────┘  │
│                             │
│  ── Artikel Terbaru ──────  │
│  ┌────┐ ┌────┐ ┌────┐      │ ← Horizontal scroll
│  │ 📄 │ │ 📄 │ │ 📄 │      │
│  └────┘ └────┘ └────┘      │
│                             │
│  ── Daily Tasks ──────────  │
│  ┌───────────────────────┐  │
│  │ ✅ Login harian  +10XP│  │
│  │ ⬜ Tulis jurnal  +15XP│  │
│  │ ⬜ Catat mood    +10XP│  │
│  └───────────────────────┘  │
│                             │
│  ┌─ BottomNav ───────────┐  │
│  │ 🏠  📖  💬  🎵  👤   │  │
│  └───────────────────────┘  │
│  ┌─┐                       │
│  │⚡│ ← FAB Daily Tasks     │
│  └─┘   (gradient orange)   │
└─────────────────────────────┘
```

### 5.4 AI Chat

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `ChatListScreen` | Daftar sesi chat + folder | `GET /chat-sessions` |
| `ChatDetailScreen` | Chat dengan AI | `POST /chat-sessions/:uuid/messages` |

#### Desain Chat Detail

```
┌─────────────────────────────┐
│  ← Sesi Chat #1      ⋮     │ ← AppBar
│─────────────────────────────│
│                             │
│        ┌─────────────┐      │
│        │ Halo! Ada    │      │ ← AI bubble (bg: #FEE2E2)
│        │ yang bisa    │      │
│        │ saya bantu?  │      │
│        └─────────────┘      │
│                             │
│  ┌─────────────┐           │
│  │ Saya merasa  │           │ ← User bubble (bg: #EF4444, text white)
│  │ cemas akhir  │           │
│  │ akhir ini    │           │
│  └─────────────┘           │
│                             │
│        ┌─────────────┐      │
│        │ Saya mengerti│      │
│        │ perasaan     │      │
│        │ Anda...      │      │
│        └─────────────┘      │
│                             │
│─────────────────────────────│
│ ┌─────────────────────┐ 📤 │ ← Input bar
│ │ Ketik pesan...      │     │
│ └─────────────────────┘     │
└─────────────────────────────┘

AI Bubble:
  bg: #FEF2F2 (red-50), border: 1dp #FEE2E2
  text: #111827, radius: 16dp (topLeft: 4dp)

User Bubble:
  bg: #EF4444 (primary)
  text: #FFFFFF, radius: 16dp (topRight: 4dp)
```

### 5.5 Journal

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `JournalListScreen` | Daftar jurnal + search + filter | `GET /journals` |
| `JournalCreateScreen` | Editor jurnal baru | `POST /journals` |
| `JournalDetailScreen` | Lihat & edit jurnal | `GET/PUT /journals/:uuid` |

### 5.6 Mood Tracker

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `MoodTrackerScreen` | Input mood + history | `POST /user-moods`, `GET /user-moods` |
| `MoodStatsScreen` | Statistik & grafik mood | `GET /user-moods/stats` |

#### Mood Emoji Mapping

```
😊 Happy    → assets/images/moods/1-happy.png
😌 Calm     → assets/images/moods/2-calm.png
😐 Neutral  → assets/images/moods/3-neutral.png
😔 Sad      → assets/images/moods/4-sad.png  
😢 Cry      → assets/images/moods/5-cry.png
😡 Angry    → assets/images/moods/6-angry.png
😰 Anxious  → assets/images/moods/7-anxious.png
😫 Stressed → assets/images/moods/8-stressed.png
```

### 5.7 Music Player

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `MusicHomeScreen` | Kategori + playlist publik | `GET /song-categories`, `GET /playlists/public` |
| `PlaylistDetailScreen` | Lagu dalam playlist | `GET /playlists/:uuid` |
| `MusicPlayerScreen` | Full screen player | - |

> **Mini Player**: Widget persisten di atas BottomNavBar saat lagu sedang diputar, mirip implementasi web (GlobalMusicPlayer).

### 5.8 Breathing Exercise

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `BreathingHomeScreen` | Daftar teknik + favorit + stats | `GET /breathing/techniques`, `GET /breathing/stats` |
| `BreathingSessionScreen` | Timer animasi pernapasan | `POST /breathing/sessions`, `POST .../complete` |

### 5.9 Community & Forum

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `ForumListScreen` | Daftar forum + kategori | `GET /forums` |
| `ForumDetailScreen` | Forum + daftar post | `GET /forums/:slug` |
| `ForumCreateScreen` | Buat forum baru | `POST /forums` |
| `StoryListScreen` | Cerita inspiratif | `GET /stories` |
| `StoryDetailScreen` | Detail cerita + komentar | `GET /stories/:id` |
| `StoryCreateScreen` | Tulis cerita baru | `POST /stories` |

### 5.10 Article / Reading

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `ArticleListScreen` | Daftar artikel + kategori | `GET /articles` |
| `ArticleDetailScreen` | Baca artikel | `GET /articles/:slug` |

### 5.11 Gamification

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `GameHubScreen` | Hub gamification utama | Multiple endpoints |
| `BadgesScreen` | Koleksi badge | `GET /badges/my-badges` |
| `LeaderboardScreen` | Peringkat mingguan | `GET /leaderboard` |
| `DailyTasksScreen` | Daftar tugas harian | `GET /daily-tasks` |
| `ProgressMapScreen` | Peta perjalanan | `GET /map` |
| `GuildScreen` | Guild & anggota | `GET /guilds/my-guild` |
| `DailySpinScreen` | Roda hadiah harian | `GET/POST /daily-spin/*` |
| `RewardsShopScreen` | Toko reward (coins) | `GET /rewards` |

### 5.12 Profile & Settings

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `ProfileScreen` | Profil user + stats | `GET /auth/me` |
| `EditProfileScreen` | Edit nama, avatar | `PUT /auth/profile` |
| `SettingsScreen` | Pengaturan app | - |

### 5.13 Billing / Premium

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `PremiumScreen` | Daftar plan + upgrade | `GET /billing/catalog` |
| `TransactionHistoryScreen` | Riwayat transaksi | `GET /billing/transactions` |

### 5.14 Notification

| Screen | Deskripsi | API |
|--------|-----------|-----|
| `NotificationScreen` | Daftar notifikasi | `GET /notifications` |

---

## 6. API Integration

### 6.1 HTTP Client Setup

```dart
// Menggunakan Dio sebagai HTTP client
// Base URL: dari environment variable atau config
// Headers: { "Authorization": "Bearer <token>", "Content-Type": "application/json" }
// Interceptors:
//   1. AuthInterceptor — inject token dari secure storage
//   2. ErrorInterceptor — handle 401 (logout), 429 (rate limit), 500
//   3. LoggingInterceptor — log request/response di debug mode
//   4. RetryInterceptor — retry pada network error (max 3x)
```

### 6.2 Endpoint Priority Map (Sesuai fase pengembangan)

**Fase 1 (Core)**:
- Auth: `/auth/register`, `/auth/login`, `/auth/me`, `/auth/profile`, `/auth/password`, `/auth/forgot-password`
- Journal: `/journals` (CRUD + search)
- Mood: `/user-moods` (CRUD + stats)
- Chat: `/chat-sessions` (CRUD), `/chat-messages`

**Fase 2 (Content & Community)**:
- Articles: `/articles`, `/article-categories`
- Forum: `/forums`, `/posts`, `/forum-categories`
- Stories: `/stories` (CRUD + comments + hearts)
- Music: `/song-categories`, `/songs`, `/playlists`

**Fase 3 (Gamification & Premium)**:
- Gamification: `/daily-tasks`, `/badges`, `/map`, `/guilds`, `/leaderboard`, `/rewards`, `/daily-spin`, `/exp-history`, `/combo`, `/chests`
- Breathing: `/breathing/*`
- Billing: `/billing/*`
- Notifications: `/notifications`, `/push`

**Fase 4 (Wellness & Advanced)**:
- Wellness: `/wellness/*`
- Search: `/search`
- Upload: `/upload/image`, `/upload/audio`

---

## 7. State Management

### BLoC Pattern

Setiap fitur memiliki BLoC sendiri:

```
AuthBloc          → Login, register, logout, profile state
ChatBloc          → Chat sessions, messages
JournalBloc       → Journal CRUD, search, filter
MoodBloc          → Mood tracking, statistics
MusicBloc         → Songs, playlists, player state
BreathingBloc     → Techniques, sessions, timer
ForumBloc         → Forums, posts, voting
StoryBloc         → Stories, comments, hearts
ArticleBloc       → Articles, categories
GamificationBloc  → XP, levels, badges, daily tasks
NotificationBloc  → Notification list, unread count
BillingBloc       → Plans, subscription status
ProfileBloc       → User profile, settings
```

### Global State (selalu tersedia)

```
AuthBloc          → User session (token + user data)
NotificationBloc  → Unread count (badge di nav)
MusicPlayerBloc   → Current playing song (mini player)
GamificationBloc  → XP/Level/Streak (header display)
```

---

## 8. Navigasi & Routing

### GoRouter Configuration

```
/                           → SplashScreen (redirect logic)
/onboarding                 → OnboardingScreen
/login                      → LoginScreen
/register                   → RegisterScreen
/forgot-password            → ForgotPasswordScreen
/reset-password             → ResetPasswordScreen

# Shell Route (MainLayout dengan BottomNav)
/home                       → HomeScreen
/journal                    → JournalListScreen
  /journal/create           → JournalCreateScreen
  /journal/:uuid            → JournalDetailScreen
/chat                       → ChatListScreen
  /chat/:uuid               → ChatDetailScreen
/music                      → MusicHomeScreen
  /music/playlist/:uuid     → PlaylistDetailScreen
  /music/player             → MusicPlayerScreen
/profile                    → ProfileScreen
  /profile/edit             → EditProfileScreen
  /profile/settings         → SettingsScreen

# Non-tab routes (tanpa BottomNav)
/mood                       → MoodTrackerScreen
  /mood/stats               → MoodStatsScreen
/breathing                  → BreathingHomeScreen
  /breathing/session/:id    → BreathingSessionScreen
/forum                      → ForumListScreen
  /forum/create             → ForumCreateScreen
  /forum/:slug              → ForumDetailScreen
/stories                    → StoryListScreen
  /stories/create           → StoryCreateScreen
  /stories/:id              → StoryDetailScreen
/articles                   → ArticleListScreen
  /articles/:slug           → ArticleDetailScreen
/game                       → GameHubScreen
  /game/badges              → BadgesScreen
  /game/leaderboard         → LeaderboardScreen
  /game/daily-tasks         → DailyTasksScreen
  /game/progress-map        → ProgressMapScreen
  /game/guild               → GuildScreen
  /game/daily-spin          → DailySpinScreen
  /game/rewards             → RewardsShopScreen
/notifications              → NotificationScreen
/premium                    → PremiumScreen
  /premium/transactions     → TransactionHistoryScreen
```

### Bottom Navigation Tabs

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Home | `Icons.home_rounded` | `/home` |
| 1 | Journal | `Icons.book_rounded` | `/journal` |
| 2 | Chat | `Icons.chat_rounded` | `/chat` |
| 3 | Music | `Icons.music_note_rounded` | `/music` |
| 4 | Profile | `Icons.person_rounded` | `/profile` |

---

## 9. Dependency / Package

### Core

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `flutter_bloc` | ^9.x | State management (BLoC pattern) |
| `go_router` | ^14.x | Declarative routing |
| `dio` | ^5.x | HTTP client |
| `get_it` | ^8.x | Dependency injection |
| `injectable` | ^2.x | Code generation untuk DI |
| `equatable` | ^2.x | Value equality untuk BLoC states |

### Data & Storage

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `json_annotation` | ^4.x | JSON serialization annotations |
| `json_serializable` | ^6.x | JSON code generation |
| `build_runner` | ^2.x | Code generation runner |
| `flutter_secure_storage` | ^9.x | Secure token storage |
| `hive_flutter` | ^1.x | Local database (cache) |
| `connectivity_plus` | ^6.x | Network connectivity check |

### UI

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `google_fonts` | ^6.x | Plus Jakarta Sans & Nunito |
| `flutter_svg` | ^2.x | SVG rendering |
| `cached_network_image` | ^3.x | Image caching |
| `shimmer` | ^3.x | Loading skeleton |
| `lottie` | ^3.x | Animasi Lottie (breathing, onboarding) |
| `fl_chart` | ^0.69.x | Grafik mood & statistik |
| `flutter_html` | ^3.x | Render HTML artikel/forum |

### Media

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `just_audio` | ^0.9.x | Audio player untuk musik |
| `audio_service` | ^0.18.x | Background audio playback |
| `audio_session` | ^0.1.x | Audio session management |

### Notifications

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `firebase_messaging` | ^15.x | Push notifications (FCM) |
| `flutter_local_notifications` | ^18.x | Local notification display |

### Form & Validation

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `formz` | ^0.7.x | Form validation |
| `image_picker` | ^1.x | Pilih foto dari galeri/kamera |

### Utils

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `intl` | ^0.19.x | Format tanggal Indonesia |
| `url_launcher` | ^6.x | Buka link external |
| `share_plus` | ^10.x | Share konten |
| `package_info_plus` | ^8.x | App version info |
| `permission_handler` | ^11.x | Runtime permissions |

---

## 10. Fase Pengembangan

### Fase 1: Foundation & Core Features (Minggu 1-3)

**Minggu 1 — Setup & Auth**
- [ ] Setup project structure (folder, DI, theme, router)
- [ ] Implementasi Design System (AppColors, AppTypography, AppDimensions)
- [ ] Implementasi custom fonts (Plus Jakarta Sans, Nunito)
- [ ] Build reusable widgets (AppButton, AppCard, AppInput, AppDialog, dll.)
- [ ] Setup Dio HTTP client + interceptors
- [ ] Implementasi Auth (Login, Register, Forgot Password)
- [ ] Secure token storage
- [ ] Auth state management (AuthBloc)
- [ ] Route protection (redirect jika belum login)
- [ ] Splash screen + Onboarding

**Minggu 2 — Journal & Mood**
- [ ] Journal list screen (search, filter, sort)
- [ ] Journal create/edit screen (rich text editor)
- [ ] Journal detail screen
- [ ] Journal local cache (offline support)
- [ ] Mood tracker screen (emoji picker + catatan)
- [ ] Mood history & statistics screen
- [ ] Mood chart (fl_chart)
- [ ] Mood local cache

**Minggu 3 — AI Chat**
- [ ] Chat session list screen + folder management
- [ ] Chat detail screen (bubble UI)
- [ ] Send message & receive AI response
- [ ] Chat session CRUD (create, delete, favorite, trash)
- [ ] Chat message actions (like, dislike, pin)
- [ ] Daily message limit handling

### Fase 2: Content & Community (Minggu 4-6)

**Minggu 4 — Music & Breathing**
- [ ] Music home screen (categories + public playlists)
- [ ] Playlist detail screen
- [ ] Audio player integration (just_audio + audio_service)
- [ ] Mini player (persisten widget)
- [ ] Background playback
- [ ] Playlist CRUD (user playlists)
- [ ] Breathing technique list screen
- [ ] Breathing session screen (animated timer)
- [ ] Breathing stats & favorites

**Minggu 5 — Forum & Stories**
- [ ] Forum list screen (categories, search, sort)
- [ ] Forum detail screen (posts, voting, accepted answer)
- [ ] Create forum & post
- [ ] Post actions (upvote, downvote, report)
- [ ] Story list screen (featured, most appreciated)
- [ ] Story detail screen (comments, hearts)
- [ ] Create & manage stories

**Minggu 6 — Articles & Community**
- [ ] Article list screen (categories)
- [ ] Article detail screen (HTML rendering)
- [ ] User articles management (my articles)
- [ ] Community stats screen
- [ ] Block user functionality
- [ ] Report content functionality

### Fase 3: Gamification & Premium (Minggu 7-9)

**Minggu 7 — Gamification Core**
- [ ] Game Hub screen (overview)
- [ ] XP bar & level display
- [ ] Daily Tasks screen + claim rewards
- [ ] Badge collection screen
- [ ] Leaderboard screen (weekly)
- [ ] Streak tracking & display
- [ ] XP boost & combo status

**Minggu 8 — Gamification Advanced**
- [ ] Progress Map screen (interactive map)
- [ ] Guild system (create, join, manage, challenges)
- [ ] Daily Spin (wheel animation)
- [ ] Mystery Chest (open animation)
- [ ] Rewards Shop (claim with gold coins)
- [ ] Friend Quest system

**Minggu 9 — Billing & Notifications**
- [ ] Premium plans screen
- [ ] Checkout flow (Midtrans WebView)
- [ ] Subscription status display
- [ ] Transaction history
- [ ] Top-up gold coins
- [ ] Push notification setup (FCM)
- [ ] In-app notification list
- [ ] Notification badge (unread count)

### Fase 4: Polish & Advanced (Minggu 10-12)

**Minggu 10 — Wellness & Search**
- [ ] Wellness onboarding flow
- [ ] Wellness plan (current plan, complete items)
- [ ] Weekly insight screen
- [ ] Journey map
- [ ] Global search
- [ ] Image & audio upload

**Minggu 11 — Offline & Performance**
- [ ] Offline support (journal, mood sync)
- [ ] Image caching optimization
- [ ] Lazy loading & pagination
- [ ] Error handling & retry logic
- [ ] Loading states (shimmer/skeleton)
- [ ] Empty states

**Minggu 12 — Testing & Deployment**
- [ ] Unit tests (BLoC, repositories, use cases)
- [ ] Widget tests (key screens)
- [ ] Integration tests (critical flows)
- [ ] App icon & splash screen setup
- [ ] Android build configuration
- [ ] iOS build configuration
- [ ] Play Store & App Store preparation

---

## Catatan Penting

1. **TIDAK MENGUBAH** kode apapun di `ruang-tenang-api` dan `ruang-tenang-web`
2. Mobile app mengkonsumsi API yang sama persis dengan web
3. Push notification di mobile menggunakan **Firebase Cloud Messaging (FCM)** — berbeda dengan web yang menggunakan Web Push/VAPID. Backend mungkin perlu endpoint tambahan untuk FCM registration, tapi itu urusan nanti
4. Payment gateway (Midtrans) di mobile bisa dihandle via **WebView** untuk Snap payment page
5. Audio streaming: Web menggunakan HTML5 audio, mobile menggunakan `just_audio` yang lebih powerful (background play, lock screen controls)
6. Rich text editor: Web menggunakan Tiptap, mobile bisa menggunakan `flutter_quill` atau simplified markdown editor
7. Tema alternatif (Ocean Calm, Forest Zen, Sunset Warmth) bisa diimplementasikan setelah core selesai via ThemeData switching
8. Admin dan Mitra dashboard **tidak dimasukkan** ke mobile app — fitur ini tetap diakses via web karena lebih cocok untuk desktop/tablet interface

---

> **Status**: MENUNGGU KOREKSI
>
> Planning ini siap untuk direview. Silakan koreksi sebelum memulai pengembangan.
