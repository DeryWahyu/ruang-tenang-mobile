# Panduan Visual dan Maskot Ruang Tenang Mobile

Panduan ini membawa bahasa visual website Ruang Tenang ke aplikasi mobile. Terapkan pada screen member, komponen bersama, dan aset ilustrasi. Kode tetap menjadi sumber kebenaran untuk perilaku dan implementasi.

## Arah visual

- Jadikan RuNa bagian utama dari komposisi ketika sebuah screen memperkenalkan fitur, menyambut pengguna, memberi dukungan, atau menampilkan empty state. Pose harus membantu menjelaskan suasana atau tindakan pada screen.
- Pertahankan visual yang hangat dan tenang: bidang terang, aksen warna sesuai tema fitur, border lembut, sudut membulat, bayangan tipis, judul yang jelas, dan ruang yang cukup untuk teks serta kontrol.
- Gunakan token warna mobile seperti `AppColors` dan gaya komponen yang sudah ada. Ikuti padanan warna aksen dan suasana pada website; jangan menciptakan palet global baru di dalam screen.
- Utamakan ilustrasi maskot dengan latar transparan. Ornamen seperti lingkaran, cahaya lembut, kertas, atau elemen kecil sebaiknya menjadi lapisan UI terpisah agar bisa disusun ulang mengikuti ukuran layar.
- Gunakan gerak secukupnya untuk respons atau transisi yang bermakna. Hormati pengaturan reduced motion dan jangan membuat dekorasi bergerak mengganggu keterbacaan.

## Komposisi hero dan card

- Maskot boleh menonjol melewati tepi atas, bawah, atau samping card. Atur posisinya pada lapisan terpisah—misalnya dengan `Stack` dan `Positioned`—serta biarkan bagian yang sengaja melampaui bingkai tetap terlihat.
- Jangan memasang clipping pada seluruh card/hero jika clipping itu memotong maskot. Jika dekorasi latar perlu dipotong mengikuti sudut card, clip hanya lapisan dekorasinya; biarkan lapisan maskot berada di atas atau di luar lapisan tersebut.
- Sisakan jalur aman untuk judul, deskripsi, dan tombol. Lebar teks dan ukuran maskot harus menyesuaikan ruang yang tersedia, terutama pada layar sempit dan ketika ukuran teks sistem membesar.
- Jaga proporsi dan bentuk aset: gunakan `BoxFit.contain` atau padanan yang tidak meregangkan ilustrasi, dan hindari memotong kepala, orb, atau atribut penting tanpa alasan komposisi yang jelas.
- Pastikan maskot tidak menutupi area sentuh, informasi penting, indikator status, maupun overlay global seperti mini-player dan FAB.
- Untuk maskot yang murni dekoratif, keluarkan dari semantics. Jika pose menyampaikan informasi yang tidak ada pada teks, berikan deskripsi aksesibel yang bermakna.
- Untuk daftar horizontal, tampilkan bagian kartu berikutnya sebagai petunjuk visual dan beri instruksi geser yang singkat. Jangan mengandalkan gestur tersembunyi saja untuk menunjukkan bahwa masih ada konten.

Onboarding memakai empat background portrait layar penuh bernuansa krem, rose, dan coral. Background hanya berisi ilustrasi serta suasana; copy, indikator, tombol, dan aksi lewati dibuat sebagai komponen Flutter agar tetap tajam dan responsif. Semua slide menempatkan copy langsung di atas gradasi lembut yang menyatu dengan ilustrasi, tanpa card teks. Wajah, gestur, dan atribut RuNa tetap menjadi fokus ilustrasi. Aset runtime `assets/images/mascot/onboarding-{listen,journal,breathe,community}-bg.webp` berasal dari PNG di `docs/references/mascot/onboarding/fullscreen/`.

Splash menonjolkan mark resmi `assets/icon/app_icon.png` dalam bidang terang yang cukup besar, lalu menempatkan nama Ruang Tenang dan tagline di dekatnya. Gunakan aset mark yang sudah ada; jangan membuat ulang logo lewat image generation. Ilustrasi transparan `chat-welcome.webp` boleh muncul dari tepi bawah sebagai pendamping tanpa menutupi identitas merek atau status loading.

Mood check-in mobile mengikuti susunan website pada `MoodCheckinModal.tsx` dan `mood-checkin.css`: hero blush dengan label check-in dan copy di sisi kiri, ilustrasi check-in di sisi kanan, lalu grid pilihan mood pada bidang putih. Letakkan maskot pada lapisan terpisah supaya dapat melampaui batas hero dan masuk ke area panel. Potong hanya pada sudut luar dialog; jangan potong ilustrasi di batas hero. Sisakan ruang teks dan sentuh yang cukup untuk enam pilihan mood.

## Identitas RuNa

Master dan lembar turnaround kanonis ada di `docs/references/mascot/`:

- `mascot.png` adalah acuan utama untuk wajah, warna, material, dan efek cahaya.
- `mascot-turnaround.webp` adalah acuan bentuk dan proporsi dari tampak depan, samping, dan belakang.

Pertahankan identitas maskot kecuali pengguna secara eksplisit meminta perubahan: kepala bulat, badan rose-coral, cape crimson dengan lining navy, trim emas, emblem empat bidang membulat yang terinspirasi logo Ruang Tenang, dan orb dengan simbol hati serta gelombang napas. Kedua berkas tersebut adalah aset acuan dokumentasi; jangan menambahkannya ke daftar aset Flutter atau menggantinya dengan varian runtime.

## Alur generate atau edit maskot

1. Untuk setiap generasi atau edit maskot, sertakan **kedua** aset kanonis sebagai referensi. Pakai master PNG sebagai acuan tampilan utama dan warna; pakai turnaround sebagai acuan anatomi, proporsi, dan konsistensi sudut pandang.
2. Tentukan pose, ekspresi, arah gestur, serta konteks fitur sebelum membuat prompt. Screenshot website boleh menjadi acuan framing dan penempatan, tetapi bukan sumber identitas maskot.
3. Pertahankan atribut dan palet kanonis. Jangan menambahkan tulisan, wordmark, logo baru, atau watermark kecuali diminta secara eksplisit.
4. Pisahkan ornamen layout dari ilustrasi bila ornamen perlu responsif. Gunakan transparansi untuk cutout yang ditumpuk di atas UI; gunakan komposisi opaque untuk background layar penuh.
5. Simpan aset runtime yang diminta di `assets/images/mascot/` dengan format WebP yang dioptimalkan dan transparansi terjaga. Tambahkan atau perbarui pemakaian Flutter serta pendaftaran aset bila diperlukan. Aset referensi dokumentasi tetap berada di `docs/references/mascot/` dan tidak dikirim dalam aplikasi.
6. Jangan menimpa master atau turnaround. Jangan menghasilkan pose baru hanya dari pose turunan; selalu mulai dari dua referensi kanonis.

## Pemeriksaan sebelum selesai

- Cocokkan kembali kepala, cape, emblem, orb, warna, dan proporsi terhadap kedua referensi.
- Tinjau komposisi pada layar sempit dan lebar: teks terbaca, maskot tidak terpotong tanpa sengaja, dan elemen interaktif tetap mudah disentuh.
- Pastikan aset runtime memakai nama/path yang konsisten dengan penggunaannya, transparansi tetap baik, dan tidak ada varian duplikat yang tidak diperlukan.
- Hindari ikon bintang atau sparkle sebagai penanda AI/dekorasi umum. Pilih ikon sesuai fungsi, mengikuti aturan ikon pada `AGENTS.md`.
