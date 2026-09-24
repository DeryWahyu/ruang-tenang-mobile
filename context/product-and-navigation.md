# Produk dan Navigasi
## Scope

Aplikasi ini adalah client mobile khusus member/pengguna akhir. Admin, moderator operasional, dan mitra B2B tetap menggunakan web.

## Fitur aktif

Home, journal, mood check-in/statistics, chat AI, music/playlist, articles, stories, forum, wellness onboarding/plan, global search, community statistics, premium/billing/top-up, profile/settings, dan game offline.

Gamifikasi yang dipertahankan dan selaras dengan web: game hub, daily tasks, badges, leaderboard, progress map, rewards, EXP history, dan XP boost. Jangan menghidupkan kembali screen secondary gamification yang sudah dihapus dari product scope tanpa keputusan baru.

## Bottom navigation

- Home: home dan akses fitur harian.
- Journal: list, create, detail.
- Chat: session list, new session, detail.
- Music: music home dan playlist.
- Profile: profile, edit, password, settings, premium/transactions.

Fitur lain diakses dari Home, Profile, atau Game Hub. Route truth berada di lib/core/router/app_router.dart; jangan hanya menambah entry menu tanpa route guard dan screen.

## UX invariants

Setiap feature harus memiliki loading/error/empty state, mendukung dark/light theme yang tersedia, tidak menabrak global mini-player/FAB, dan menangani offline secara aman. Game Mindful Runner boleh berjalan offline; data server tetap membutuhkan koneksi.
Login member yang membutuhkan verifikasi nomor diarahkan ke `/verify-phone`. Nomor WhatsApp diminta saat registrasi dan dapat diubah pada edit profil. Akun lama tanpa nomor dapat mengisinya pada layar verifikasi. OTP diterbitkan backend melalui Fonnte; aplikasi menyimpan token login hanya setelah OTP benar. Reset kata sandi dikirim ke WhatsApp terverifikasi.
Riwayat billing menampilkan jumlah refund yang terkonfirmasi atau masih menunggu konfirmasi Midtrans, serta memberi tahu member saat transaksi sedang ditinjau operator.
