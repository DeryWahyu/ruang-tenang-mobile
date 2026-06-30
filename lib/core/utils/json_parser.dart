/// Utilitas parsing JSON yang dipakai bersama oleh seluruh layer `data/models`.
///
/// Tujuan keberadaan file ini (design principle):
/// - **DRY**: sebelumnya helper seperti `_parseDate`, `_int`, `_str`, dsb.
///   disalin ulang di hampir setiap file model. Sekarang satu sumber kebenaran.
/// - **Konsisten & aman**: semua model mem-parse tipe primitif dengan cara
///   yang sama dan tahan terhadap nilai `null` / tipe tak terduga dari API.
///
/// STANDAR UNTUK PHASE BERIKUTNYA:
/// Saat menambah model baru, gunakan helper di sini melalui kelas [Json]
/// (mis. `Json.date(json['created_at'])`) alih-alih menulis helper lokal.
library;

/// Kumpulan helper statis untuk mem-parse nilai dinamis dari payload JSON
/// menjadi tipe Dart yang aman.
///
/// Contoh pemakaian di sebuah model:
/// ```dart
/// factory FooModel.fromJson(Map<String, dynamic> json) => FooModel(
///       id: Json.string(json['id']),
///       count: Json.intValue(json['count']),
///       ratio: Json.doubleValue(json['ratio']),
///       active: Json.boolValue(json['is_active']),
///       createdAt: Json.date(json['created_at']) ?? DateTime.now(),
///       tags: Json.list(json['tags'], (e) => e.toString()),
///     );
/// ```
class Json {
  const Json._();

  /// Mem-parse string tanggal ISO-8601 menjadi [DateTime] lokal.
  ///
  /// Mengembalikan `null` bila nilai `null`, bukan string, string kosong,
  /// atau gagal di-parse — sehingga pemanggil bisa memberi nilai default
  /// sendiri (mis. `Json.date(...) ?? DateTime.now()`).
  static DateTime? date(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Mem-parse nilai numerik (int/double/num) menjadi [int].
  /// Default `0` bila `null` atau bukan angka.
  static int intValue(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Mem-parse nilai numerik menjadi [double].
  /// Default `0.0` bila `null` atau bukan angka.
  static double doubleValue(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Mem-parse nilai apa pun menjadi [String].
  /// Default string kosong bila `null`.
  static String string(dynamic value, {String fallback = ''}) {
    return value?.toString() ?? fallback;
  }

  /// Mem-parse nilai menjadi [bool]. Menerima bool asli maupun
  /// representasi umum dari API (`"true"`, `1`).
  /// Default `false` bila tidak dikenali.
  static bool boolValue(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return fallback;
  }

  /// Mem-parse sebuah list JSON menjadi `List<T>` dengan memetakan tiap
  /// elemen lewat [mapper]. Mengembalikan list kosong bila nilai bukan list.
  ///
  /// Cocok untuk daftar objek bersarang:
  /// ```dart
  /// items: Json.list(
  ///   json['items'],
  ///   (e) => ItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
  /// ),
  /// ```
  static List<T> list<T>(dynamic value, T Function(dynamic element) mapper) {
    if (value is! List) return <T>[];
    return value.map(mapper).toList();
  }

  /// Helper khusus untuk objek bersarang berupa `Map<String, dynamic>`.
  /// Mengembalikan `null` bila nilai bukan map.
  static Map<String, dynamic>? object(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
