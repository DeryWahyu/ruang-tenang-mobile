# Ecosystem Ruang Tenang
| Client | Konfigurasi | Scope |
| --- | --- | --- |
| Web | NEXT_PUBLIC_API_BASE_URL lengkap /api/v1 | Member, admin/moderator, mitra |
| Mobile | BASE_URL host-only lalu ApiClient menambah /api/v1 | Member |
| API | route /api/v1 | Sumber data, auth, OpenAPI |

Mobile berbagi data dan contract dengan web melalui API yang sama. Perubahan API harus dicek pada datasource/model mobile, service/schema web, migration, dan docs/openapi.yaml.

Mobile tidak memiliki feature admin/mitra. Jangan menambahkan credential atau endpoint privileged ke aplikasi hanya karena endpoint tersedia di backend. Perhatikan auth, ownership, journal/chat/mood privacy, pagination, upload URL, timezone, dan entitlement pada setiap perubahan.

Menu member web menjadi acuan paritas mobile: Home, Jurnal, Chat, Musik, Mood Tracker, Komunitas, Artikel, Perjalanan, Paket & Koin, Mini Game, serta Profil. Redirect web yang tidak lagi memiliki halaman fitur sendiri tidak perlu menjadi layar mobile terpisah. Maskot RuNa dan Bulan Pulih memakai aset WebP yang sama agar pengenalan fitur dan identitas visual konsisten.

## Invariant lintas repo

- API dan snapshot OpenAPI adalah sumber contract HTTP. Web dan mobile mengonsumsi `/api/v1` yang sama dengan konfigurasi base URL masing-masing.
- Perubahan route/DTO harus menjaga kompatibilitas kedua client dan ditinjau pada handler/test/OpenAPI API, service/schema web, serta datasource/model mobile.
- Web melayani member, admin, moderator, dan mitra; mobile hanya member (`user`). Pemeriksaan role dan ownership yang melindungi data harus tetap dilakukan API. API menyimpan state consent AI; client menjaga gate/disclaimer chat dan tidak menganggap gate UI sebagai kontrol akses server.
- Journal, chat/context AI, mood, profil, laporan moderasi, dan billing adalah data pribadi. Consent AI dan pengaturan privasi journal harus dihormati di semua client.
- Prompt/model AI, kuota, moderasi, dan kebijakan krisis berada di API. Client mempertahankan consent/disclaimer serta menangani response/error menurut contract.

Peta surface member web/mobile ada di `member-feature-parity.md` pada repo web dan mobile. Kedua salinan perlu diperbarui bersama saat surface member berubah.
