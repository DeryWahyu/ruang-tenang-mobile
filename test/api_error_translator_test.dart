import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_tenang_mobile/core/network/api_error_translator.dart';

void main() {
  group('ApiErrorTranslator', () {
    test('translates invalid email or password correctly', () {
      expect(
        ApiErrorTranslator.translate('invalid email or password'),
        equals('Email atau kata sandi salah.'),
      );
      expect(
        ApiErrorTranslator.translate('Invalid Email Or Password'),
        equals('Email atau kata sandi salah.'),
      );
    });

    test('translates standard English API errors to Indonesian', () {
      expect(
        ApiErrorTranslator.translate('user not found'),
        equals('Pengguna tidak ditemukan.'),
      );
      expect(
        ApiErrorTranslator.translate('email already registered'),
        equals('Email sudah terdaftar.'),
      );
      expect(
        ApiErrorTranslator.translate('unauthorized'),
        equals('Autentikasi diperlukan, silakan login kembali.'),
      );
      expect(
        ApiErrorTranslator.translate('forbidden'),
        equals('Anda tidak memiliki akses.'),
      );
      expect(
        ApiErrorTranslator.translate('too many requests'),
        equals('Terlalu banyak permintaan, coba lagi nanti.'),
      );
      expect(
        ApiErrorTranslator.translate('internal server error'),
        equals('Terjadi kesalahan pada server.'),
      );
      expect(
        ApiErrorTranslator.translate('upload failed'),
        equals('Gagal mengunggah berkas.'),
      );
    });

    test('translates Go validator format errors to user-friendly message', () {
      const rawValidationError =
          "Key: 'CreateArticleRequest.Title' Error:Field validation for 'Title' failed on the 'min' tag";
      expect(
        ApiErrorTranslator.translate(rawValidationError),
        equals('Data yang dimasukkan belum valid. Mohon periksa kembali isian Anda.'),
      );
    });

    test('retains messages that are already in Indonesian', () {
      const idMessage = 'Email atau kata sandi salah';
      expect(ApiErrorTranslator.translate(idMessage), equals(idMessage));

      const customIdMessage = 'Akses Anda untuk membuat jurnal sedang diblokir';
      expect(ApiErrorTranslator.translate(customIdMessage), equals(customIdMessage));
    });

    test('handles null or empty string safely', () {
      expect(ApiErrorTranslator.translate(null), equals('Terjadi kesalahan'));
      expect(ApiErrorTranslator.translate(''), equals('Terjadi kesalahan'));
      expect(ApiErrorTranslator.translate('   '), equals('Terjadi kesalahan'));
    });
  });
}
