# Produk dan Navigasi
## Scope

Aplikasi ini adalah client mobile khusus member/pengguna akhir. Admin, moderator operasional, dan mitra B2B tetap menggunakan web.

## Fitur aktif

Home, journal, mood check-in/statistics, chat AI, music/playlist, breathing, articles, stories, forum, wellness onboarding/plan, global search, community statistics, premium/billing/top-up, profile/settings, dan game offline.

Gamifikasi yang dipertahankan dan selaras dengan web: game hub, daily tasks, badges, leaderboard, progress map, rewards, guild, EXP history, dan XP boost. Jangan menghidupkan kembali screen secondary gamification yang sudah dihapus dari product scope tanpa keputusan baru.

## Bottom navigation

- Home: home dan akses fitur harian.
- Journal: list, create, detail.
- Chat: session list, new session, detail.
- Music: music home dan playlist.
- Profile: profile, edit, password, settings, premium/transactions.

Fitur lain diakses dari Home, Profile, atau Game Hub. Route truth berada di lib/core/router/app_router.dart; jangan hanya menambah entry menu tanpa route guard dan screen.

## UX invariants

Setiap feature harus memiliki loading/error/empty state, mendukung dark/light theme yang tersedia, tidak menabrak global mini-player/FAB, dan menangani offline secara aman. Game Mindful Runner boleh berjalan offline; data server tetap membutuhkan koneksi.
