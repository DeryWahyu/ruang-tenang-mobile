class ApiErrorTranslator {
  ApiErrorTranslator._();

  static const Map<String, String> _translations = {
    'invalid email or password': 'Email atau kata sandi salah.',
    'user not found': 'Pengguna tidak ditemukan.',
    'email already registered': 'Email sudah terdaftar.',
    'email already taken': 'Email sudah terdaftar.',
    'unauthorized': 'Autentikasi diperlukan, silakan login kembali.',
    'forbidden': 'Anda tidak memiliki akses.',
    'not found': 'Data tidak ditemukan.',
    'internal server error': 'Terjadi kesalahan pada server.',
    'too many requests': 'Terlalu banyak permintaan, coba lagi nanti.',
    'too many requests. please try again later.': 'Terlalu banyak permintaan, coba lagi nanti.',
    'rate limit exceeded': 'Batas permintaan terlampaui, coba lagi nanti.',
    'token expired': 'Sesi telah berakhir, silakan login kembali.',
    'invalid token': 'Token tidak valid atau telah kedaluwarsa.',
    'invalid or expired token': 'Token tidak valid atau telah kedaluwarsa.',
    'failed to fetch': 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
    'network error': 'Koneksi jaringan bermasalah.',
    'an error occurred': 'Terjadi kesalahan pada server.',
    'upload failed': 'Gagal mengunggah berkas.',
    'plan not found or needs onboarding': 'Rencana kesehatan tidak ditemukan atau perlu onboarding.',
    'failed to fetch plan': 'Gagal memuat rencana kesehatan.',
  };

  /// Menerjemahkan pesan mentah (mis. dari API atau exception) ke bahasa Indonesia.
  /// Bila pesan sudah berbahasa Indonesia atau tidak ada padanan, pesan asli dipertahankan.
  static String translate(String? rawMessage) {
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return 'Terjadi kesalahan';
    }
    final trimmed = rawMessage.trim();
    final lower = trimmed.toLowerCase();

    // 1. Padanan langsung
    final translated = _translations[lower];
    if (translated != null) {
      return translated;
    }

    // 2. Deteksi pesan validasi tag dari backend Go validator
    final validationMatch = RegExp(
      r"validation for '([^']+)' failed on the '([^']+)' tag",
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (validationMatch != null) {
      return 'Data yang dimasukkan belum valid. Mohon periksa kembali isian Anda.';
    }

    return trimmed;
  }
}
