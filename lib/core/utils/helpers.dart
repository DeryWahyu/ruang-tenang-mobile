import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Helpers {
  Helpers._();

  /// Get mood color based on mood index
  static Color getMoodColor(int moodIndex) {
    switch (moodIndex) {
      case 1: // Happy
        return const Color(0xFF22C55E);
      case 2: // Calm
        return const Color(0xFF3B82F6);
      case 3: // Neutral
        return const Color(0xFF6B7280);
      case 4: // Sad
        return const Color(0xFF8B5CF6);
      case 5: // Cry
        return const Color(0xFF6366F1);
      case 6: // Angry
        return AppColors.destructive;
      case 7: // Anxious
        return const Color(0xFFF59E0B);
      case 8: // Stressed
        return const Color(0xFFEF4444);
      default:
        return AppColors.mutedForeground;
    }
  }

  /// Get mood label
  static String getMoodLabel(int moodIndex) {
    switch (moodIndex) {
      case 1: return 'Senang';
      case 2: return 'Tenang';
      case 3: return 'Netral';
      case 4: return 'Sedih';
      case 5: return 'Menangis';
      case 6: return 'Marah';
      case 7: return 'Cemas';
      case 8: return 'Stres';
      default: return 'Tidak diketahui';
    }
  }

  /// Get mood emoji asset path
  static String getMoodAsset(int moodIndex) {
    final labels = ['happy', 'calm', 'neutral', 'sad', 'cry', 'angry', 'anxious', 'stressed'];
    if (moodIndex < 1 || moodIndex > labels.length) return '';
    return 'assets/images/moods/$moodIndex-${labels[moodIndex - 1]}.png';
  }

  /// Format number with K/M suffix
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format duration (for music player)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Parse server datetime string to local DateTime
  static DateTime? parseServerDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Remove h2 tags from HTML content
  static String stripH2Tags(String html) {
    return html.replaceAll(RegExp(r'<h2[^>]*>.*?</h2>', caseSensitive: false, dotAll: true), '');
  }
}
