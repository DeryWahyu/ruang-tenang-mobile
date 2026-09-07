# Ecosystem Ruang Tenang
| Client | Konfigurasi | Scope |
| --- | --- | --- |
| Web | NEXT_PUBLIC_API_BASE_URL lengkap /api/v1 | Member, admin/moderator, mitra |
| Mobile | BASE_URL host-only lalu ApiClient menambah /api/v1 | Member |
| API | route /api/v1 | Sumber data, auth, OpenAPI |

Mobile berbagi data dan contract dengan web melalui API yang sama. Perubahan API harus dicek pada datasource/model mobile, service/schema web, migration, dan docs/openapi.yaml.

Mobile tidak memiliki feature admin/mitra. Jangan menambahkan credential atau endpoint privileged ke aplikasi hanya karena endpoint tersedia di backend. Perhatikan auth, ownership, journal/chat/mood privacy, pagination, upload URL, timezone, dan entitlement pada setiap perubahan.
