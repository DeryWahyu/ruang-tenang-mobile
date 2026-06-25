import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppDateUtils {
  AppDateUtils._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
    }
  }

  /// "25 Juni 2026"
  static String formatFull(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  /// "25 Jun 2026"
  static String formatShort(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// "25 Jun"
  static String formatDayMonth(DateTime date) {
    return DateFormat('d MMM', 'id_ID').format(date);
  }

  /// "Rabu, 25 Juni 2026"
  static String formatWithDay(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  /// "25 Jun 2026, 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// "Baru saja", "5 menit lalu", "2 jam lalu", "Kemarin", etc.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      return formatShort(date);
    }
  }

  /// Check if same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
