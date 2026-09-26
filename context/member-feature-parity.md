# Peta Paritas Fitur Member Web dan Mobile

Dokumen ini memetakan surface fitur member untuk membantu review parity lintas platform. Ini adalah snapshot navigasi, bukan pengganti route truth pada source code. Salinan peta juga ada di repo web; perbarui keduanya saat surface member berubah.

| Area member | Web | Mobile | Catatan parity |
| --- | --- | --- | --- |
| Auth dan pemulihan akun | `/login`, `/register`, `/verify-phone`, `/forgot-password`, `/reset-password` | `/login`, `/register`, `/verify-phone`, `/forgot-password`, `/reset-password` | Alur nomor WhatsApp dan OTP; mobile hanya menerima role member. |
| Beranda dan tur fitur | `/dashboard` | `/home` | Ringkasan progres level, akses fitur harian, tur RuNa, check-in, serta pintasan Perjalanan dan Koleksi Badge pada Eksplorasi. |
| Mood | `/dashboard/mood-tracker` | Check-in modal harian di Beranda; `/mood/stats` | Tidak ada halaman pencatatan terpisah; statistik dan riwayat tetap tersedia. |
| Journal pribadi | `/dashboard/journal`, `/dashboard/journal/create`, `/dashboard/journal/[uuid]` | `/journal`, `/journal/create`, `/journal/:uuid`, `/journal/insights` | Cocokkan pencarian/filter, penulisan, analitik, privasi, ringkasan, dan ekspor dengan dokumentasi fitur masing-masing. |
| Journal publik | `/dashboard/community?tab=journals` | `/community?tab=journals`, `/community/journals/:uuid` | Daftar publik dan detail berada di area komunitas. |
| Chat AI | `/dashboard/chat` | `/chat`, `/chat/new`, `/chat/:uuid` | Pertahankan persetujuan/disclaimer dan kemampuan chat yang tersedia pada kedua client. `/dashboard/consultation` adalah redirect ke chat, bukan fitur terpisah. |
| Musik dan playlist | `/dashboard/music` | `/music`, `/music/playlist/:uuid` | Termasuk browse, pemutaran, dan playlist. |
| Forum | `/dashboard/community` tab `forum`, `/dashboard/community/forum/[slug]` | `/community?tab=forum`, `/forum`, `/forum/:slug` | Forum, kategori, lingkar dukungan, detail topik, dan pagination. |
| Kisah komunitas | `/dashboard/community?tab=stories`, `/dashboard/community/stories/*` | `/community?tab=stories`, `/stories/new`, `/stories/:id`, `/stories/edit/:id` | Termasuk daftar dan pengelolaan kisah sendiri. |
| Statistik komunitas | `/dashboard/community?tab=stats` | `/community?tab=stats` | Cocokkan statistik member dan state kosong/error. |
| Artikel | `/dashboard/articles`, `/dashboard/articles/new`, `/dashboard/articles/[slug]` | `/articles`, `/articles/new`, `/articles/edit/:id`, `/articles/:slug` | Termasuk artikel publik dan artikel sendiri. |
| Perjalanan dan gamifikasi | `/dashboard/journey` tab `summary`, `map`, `rewards`; Daily Task FAB | `/journey` tab yang sama; `/gamification/*` alias/tab; pintasan di Eksplorasi Beranda; Daily Task FAB | Ringkasan XP/badge, peta, hadiah, tugas harian, leaderboard, riwayat EXP, XP boost, dan tema akun. |
| Paket, koin, transaksi | `/dashboard/billing` tab `packages`, `coins`, `transactions` | `/billing` tab yang sama | Billing member; status pembayaran ditentukan callback Duitku di API. Transaksi pending dapat dilanjutkan dan riwayat mendukung unduh invoice CSV. |
| Mini game | `/dashboard/game` | `/game` | Mindful Runner tersedia offline. Wellness plan dan Game Hub lama adalah alias/tujuan terdahulu, bukan area parity terpisah. |
| Pencarian | Pencarian global di header dashboard | `/search` | Cocokkan jenis hasil dan deep link yang tersedia. |
| Profil dan pengaturan | `/dashboard/profile`, `/dashboard/settings` | `/profile`, `/profile/edit`, `/profile/password` | Mobile menempatkan paket premium, tentang aplikasi, kebijakan privasi, bantuan, dan keluar langsung di `/profile`; tidak ada screen pengaturan terpisah. |
| Notifikasi dan preferensi push | NotificationBell pada header; daftar, status baca, dan toggle push | Belum ditemukan surface/rute notifikasi pada inventaris mobile saat peta ini dibuat | Gap parity yang perlu ditinjau sebelum dianggap tersedia di mobile. |

## Batas scope dan pemeliharaan

- Peta ini hanya mencakup member (`user`). Admin, moderator operasional, dan mitra tetap web-only.
- Perbedaan navigasi atau kontrol native boleh mengikuti platform selama kemampuan member dan hasilnya setara.
- Route legacy yang redirect ke hub kanonis tidak dihitung sebagai fitur mandiri. Verifikasi route aktual di `lib/core/router/app_router.dart`.
- Saat fitur atau route berubah, perbarui peta ini di repo mobile dan web, lalu sinkronkan `product-and-navigation.md` dan `features-and-routes.md` sesuai repo.
- Catat gap secara eksplisit. Jangan menandai parity penuh hanya karena ada route yang namanya mirip; cocokkan perilaku dan state fiturnya.
