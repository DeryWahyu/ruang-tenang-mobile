# Produk dan Navigasi
## Scope

Aplikasi ini adalah client mobile khusus member/pengguna akhir. Admin, moderator operasional, dan mitra B2B tetap menggunakan web.

## Fitur aktif

Home dengan ringkasan dan tur fitur, jurnal pribadi dan publik (pencarian, filter tanggal/tag, mode menulis, ide menulis, analitik, ringkasan mingguan, privasi, dan ekspor), mood check-in/statistik, chat AI (persetujuan, folder, favorit, sampah, konteks, ringkasan, ekspor, pin/reaksi pesan, dikte dan audio), musik/playlist yang dapat dikelola, artikel publik dan artikel sendiri, kisah komunitas, forum (kategori, lingkar dukungan, format topik, dan paginasi), statistik komunitas, pencarian, billing paket/koin/transaksi, profil/settings, dan game offline.

Perjalanan mengikuti tiga tab web: Ringkasan, Peta, Hadiah. Tugas harian, badge, leaderboard, riwayat EXP, XP boost, riwayat klaim hadiah, dan tema akun tersedia melalui tab tersebut. Wellness plan dan Game Hub lama tidak lagi menjadi tujuan navigasi; tautan lama dialihkan ke halaman yang relevan.

## Bottom navigation

- Home: home dan akses fitur harian.
- Journal: list, create, detail.
- Chat: session list, new session, detail.
- Music: music home dan playlist.
- Profile: profile, edit, password, settings, premium/transactions.

Komunitas, Artikel, Perjalanan, dan Paket & Koin memakai tab di luar bottom navigation dan diakses dari Home/Profile. Route truth berada di lib/core/router/app_router.dart; jangan hanya menambah entry menu tanpa route guard dan screen.

## UX invariants

Setiap feature harus memiliki loading/error/empty state, mendukung dark/light theme yang tersedia, tidak menabrak global mini-player/FAB, dan menangani offline secara aman. Game Mindful Runner boleh berjalan offline; data server tetap membutuhkan koneksi.
Login member yang membutuhkan verifikasi nomor diarahkan ke `/verify-phone`. Nomor WhatsApp diminta saat registrasi dan dapat diubah pada edit profil. Akun lama tanpa nomor dapat mengisinya pada layar verifikasi. OTP diterbitkan backend melalui Fonnte; aplikasi menyimpan token login hanya setelah OTP benar. Reset kata sandi dikirim ke WhatsApp terverifikasi.
Riwayat billing menampilkan jumlah refund yang terkonfirmasi atau masih menunggu konfirmasi Midtrans, serta memberi tahu member saat transaksi sedang ditinjau operator.
Login dan pemulihan sesi menolak role selain `user`; admin dan mitra tetap memakai web. Chat AI memerlukan persetujuan disclaimer pada profil sebelum percakapan dibuka. Dikte dan perekaman audio memakai kemampuan native Android/iOS dan memerlukan izin mikrofon; dikte iOS juga memerlukan izin pengenalan suara.
