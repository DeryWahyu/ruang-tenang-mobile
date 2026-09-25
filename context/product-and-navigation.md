# Produk dan Navigasi
Peta surface member web/mobile dirangkum di `member-feature-parity.md`; kode router dan screen tetap menjadi kebenaran untuk route aktif.

## Scope

Aplikasi ini adalah client mobile khusus member/pengguna akhir. Admin, moderator operasional, dan mitra B2B tetap menggunakan web.

## Fitur aktif

Beranda dengan ringkasan dan tur fitur, jurnal pribadi dan publik (pencarian, filter tanggal/tag, mode menulis, ide menulis, analitik, ringkasan mingguan, privasi, dan ekspor), mood check-in/statistik, chat AI (persetujuan, folder, favorit, sampah, konteks, ringkasan, ekspor, pin/reaksi pesan, dikte dan audio), musik/playlist yang dapat dikelola, artikel publik dan artikel sendiri, kisah komunitas, forum (kategori, lingkar dukungan, format topik, dan paginasi), statistik komunitas, pencarian, billing paket/koin/transaksi, profil dan keamanan akun, informasi/bantuan, dan game offline.

Perjalanan mengikuti tiga tab web: Ringkasan, Peta, Hadiah. Tugas harian, badge, leaderboard, riwayat EXP, XP boost, riwayat klaim hadiah, dan tema akun tersedia melalui tab tersebut. Wellness plan dan Game Hub lama tidak lagi menjadi tujuan navigasi; tautan lama dialihkan ke halaman yang relevan.

## Bottom navigation

- Beranda (`/home`): ringkasan, progres level, check-in, serta eksplorasi fitur termasuk Perjalanan dan Koleksi Badge.
- Jurnal: list, create, detail.
- Chat: session list, new session, detail.
- Musik: music home dan playlist.
- Profil: informasi akun, edit profil, kata sandi, paket premium, tentang aplikasi, kebijakan privasi, bantuan, dan keluar.

Detail playlist (`/music/playlist/:uuid`) adalah anak route Musik di dalam
`MainLayout`, sehingga bottom navigation dan mini-player tetap tersedia.

Komunitas, Artikel, Perjalanan, dan Koleksi Badge memakai tab di luar bottom navigation dan diakses dari Eksplorasi Beranda. Paket & Koin dapat dibuka dari Beranda/Profil. Route truth berada di lib/core/router/app_router.dart; jangan hanya menambah entry menu tanpa route guard dan screen.

## UX invariants

Setiap feature harus memiliki loading/error/empty state, mendukung dark/light theme yang tersedia, tidak menabrak global mini-player/FAB, dan menangani offline secara aman. Game Mindful Runner boleh berjalan offline; data server tetap membutuhkan koneksi.
Login member yang membutuhkan verifikasi nomor diarahkan ke `/verify-phone`. Nomor WhatsApp diminta saat registrasi dan dapat diubah pada edit profil. Akun lama tanpa nomor dapat mengisinya pada layar verifikasi. OTP diterbitkan backend melalui Fonnte; aplikasi menyimpan token login hanya setelah OTP benar. Reset kata sandi dikirim ke WhatsApp terverifikasi.
Riwayat billing menampilkan jumlah refund yang terkonfirmasi atau masih menunggu konfirmasi Midtrans, serta memberi tahu member saat transaksi sedang ditinjau operator.
Login dan pemulihan sesi menolak role selain `user`; admin dan mitra tetap memakai web. Tombol Chat membuka daftar obrolan secara langsung; persetujuan disclaimer AI tampil sebagai dialog saat percakapan dibuka, dan tetap harus disimpan sebelum percakapan dapat digunakan. Dikte dan perekaman audio memakai kemampuan native Android/iOS dan memerlukan izin mikrofon; dikte iOS juga memerlukan izin pengenalan suara.
