import 'package:flutter/material.dart';

/// Sistem shadow terpusat — **selaras dengan token shadow web** di
/// `ruang-tenang-web/app/globals.css`:
///
/// ```css
/// --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
/// --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
/// --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
/// ```
///
/// Tujuan (design principle): satu sumber elevation agar seluruh kartu,
/// tombol, dan sheet punya kedalaman yang konsisten dan setara web —
/// alih-alih setiap widget menebak `BoxShadow` sendiri.
class AppShadows {
  AppShadows._();

  /// Setara `--shadow-sm`. Untuk kartu/elemen datar dengan elevasi halus.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Setara `--shadow-md`. Untuk kartu interaktif / hover.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];

  /// Setara `--shadow-lg`. Untuk elemen menonjol (FAB, dialog, kartu hero).
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];
}
