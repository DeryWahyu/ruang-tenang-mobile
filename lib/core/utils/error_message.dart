import '../network/api_exceptions.dart';

/// Utilitas untuk mengubah objek error/exception menjadi pesan yang
/// ramah ditampilkan ke pengguna.
///
/// Tujuan (design principle):
/// - **DRY**: sebelumnya pola `e.toString().replaceFirst('Exception: ', '')`
///   ditulis ulang di banyak bloc/cubit/screen (`_err`, `_msg`). Sekarang
///   terpusat di satu tempat.
/// - **SRP**: logika "menerjemahkan error → string" dipisah dari UI/state.
///
/// STANDAR UNTUK PHASE BERIKUTNYA:
/// Pada blok `catch (e)`, gunakan `ErrorMessage.from(e, 'pesan default')`
/// untuk memperoleh teks error, alih-alih membuat helper lokal.
class ErrorMessage {
  const ErrorMessage._();

  /// Mengembalikan pesan error yang layak ditampilkan dari [error].
  ///
  /// Urutan prioritas:
  /// 1. [ApiException] → memakai `message` yang sudah dilokalkan.
  /// 2. Exception umum → buang prefiks `"Exception: "` yang ditambahkan Dart.
  /// 3. Bila hasil kosong → pakai [fallback].
  static String from(Object error, [String fallback = 'Terjadi kesalahan']) {
    if (error is ApiException) {
      return error.message.isNotEmpty ? error.message : fallback;
    }
    final cleaned = error.toString().replaceFirst('Exception: ', '').trim();
    return cleaned.isEmpty ? fallback : cleaned;
  }
}
