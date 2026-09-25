import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Data kelas untuk mewakili fitur internal dalam aplikasi.
class AppFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const AppFeature(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.route,
  );
}

/// Daftar lengkap fitur aplikasi yang digunakan di halaman Home dan Global Search.
const kAllAppFeatures = <AppFeature>[
  AppFeature(
    'Teman Cerita AI',
    'Ruang untuk bercerita',
    Icons.chat_bubble_outline_rounded,
    AppColors.primary,
    '/chat',
  ),
  AppFeature(
    'Jurnal',
    'Tulis & refleksi harian',
    Icons.auto_stories_rounded,
    Color(0xFF6366F1),
    '/journal',
  ),
  AppFeature(
    'Statistik Mood',
    'Lihat pola perasaanmu',
    Icons.mood_rounded,
    Color(0xFFF59E0B),
    '/mood/stats',
  ),
  AppFeature(
    'Musik Relaksasi',
    'Dengarkan & rileks',
    Icons.headphones_rounded,
    Color(0xFF8B5CF6),
    '/music',
  ),
  AppFeature(
    'Komunitas',
    'Forum, kisah, dan jurnal publik',
    Icons.forum_rounded,
    Color(0xFF7C3AED),
    '/community',
  ),
  AppFeature(
    'Artikel',
    'Bacaan kesehatan mental',
    Icons.article_rounded,
    Color(0xFF0EA5E9),
    '/articles',
  ),
  AppFeature(
    'Perjalanan',
    'Level, EXP, dan hadiahmu',
    Icons.map_rounded,
    Color(0xFFD97706),
    '/journey',
  ),
  AppFeature(
    'Mini Game',
    'Mindful Runner (offline)',
    Icons.videogame_asset_rounded,
    Color(0xFF7C3AED),
    '/game',
  ),
  AppFeature(
    'Koleksi Badge',
    'Rayakan pencapaian kecilmu',
    Icons.emoji_events_rounded,
    Color(0xFFB45309),
    '/gamification/badges',
  ),
  AppFeature(
    'Paket & Koin',
    'Atur akses dan saldo',
    Icons.workspace_premium_rounded,
    Color(0xFFD97706),
    '/billing',
  ),
];
