import 'package:flutter/material.dart';
import '../../domain/entities/mood.dart';
import '../theme/app_colors.dart';

/// String extensions
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}

/// Context extensions for quick access
extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isSmallScreen => screenWidth < 375;
  bool get isMediumScreen => screenWidth >= 375 && screenWidth < 768;
  bool get isLargeScreen => screenWidth >= 768;

  /// Lebar terpendek perangkat (tetap sama saat orientasi berubah) — patokan
  /// terbaik membedakan ponsel vs tablet.
  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  /// Tablet bila sisi terpendek >= 600dp (konvensi Material).
  bool get isTablet => shortestSide >= 600;

  /// Apakah perangkat sedang dalam orientasi lanskap.
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Jumlah kolom grid adaptif berdasarkan lebar layar yang tersedia.
  ///
  /// Memilih kolom berdasarkan estimasi lebar minimum tiap item
  /// ([minItemWidth]) dan dibatasi [min]..[max]. Cocok untuk membuat grid
  /// nyaman di HP kecil (1–2 kolom), HP standar (2), hingga tablet/lanskap
  /// (3–4 kolom) tanpa menulis breakpoint manual di tiap layar.
  int gridColumns({double minItemWidth = 180, int min = 2, int max = 4}) {
    final columns = (screenWidth / minItemWidth).floor();
    return columns.clamp(min, max);
  }

  /// Pilih nilai berbeda menurut kelas ukuran layar. [tablet]/[large] opsional;
  /// bila null akan jatuh ke nilai sebelumnya.
  T responsiveValue<T>({required T mobile, T? tablet, T? large}) {
    if (isLargeScreen && large != null) return large;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }
}

/// Nullable string extension
extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

/// DateTime extensions
extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

/// MoodType UI extensions.
///
/// `color` requires Flutter's [Color], so it lives here (core, may import
/// Flutter) rather than in the pure-Dart `MoodType` entity. Any file that
/// accesses `someMoodType.color` must import this extensions file.
extension MoodTypeColorX on MoodType {
  Color get color {
    switch (this) {
      case MoodType.happy:
        return const Color(0xFF22C55E);
      case MoodType.neutral:
        return AppColors.mutedForeground;
      case MoodType.angry:
        return AppColors.destructive;
      case MoodType.disappointed:
        return const Color(0xFF8B5CF6);
      case MoodType.sad:
        return const Color(0xFF6366F1);
      case MoodType.crying:
        return const Color(0xFF6366F1);
    }
  }

  String get activeImagePath {
    switch (this) {
      case MoodType.happy:
        return 'assets/images/moods/1-happy-active.png';
      case MoodType.neutral:
        return 'assets/images/moods/2-netral-active.png';
      case MoodType.angry:
        return 'assets/images/moods/3-angry-active.png';
      case MoodType.disappointed:
        return 'assets/images/moods/4-disappointed-active.png';
      case MoodType.sad:
        return 'assets/images/moods/5-sad-active.png';
      case MoodType.crying:
        return 'assets/images/moods/6-cry-active.png';
    }
  }

  String get inactiveImagePath {
    switch (this) {
      case MoodType.happy:
        return 'assets/images/moods/1-smile.png';
      case MoodType.neutral:
        return 'assets/images/moods/2-netral.png';
      case MoodType.angry:
        return 'assets/images/moods/3-angry.png';
      case MoodType.disappointed:
        return 'assets/images/moods/4-disappointed.png';
      case MoodType.sad:
        return 'assets/images/moods/5-sad.png';
      case MoodType.crying:
        return 'assets/images/moods/6-cry.png';
    }
  }
}