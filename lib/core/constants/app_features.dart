import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Data kelas untuk mewakili fitur internal dalam aplikasi.
class AppFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const AppFeature(this.title, this.subtitle, this.icon, this.color, this.route);
}

/// Daftar lengkap fitur aplikasi yang digunakan di halaman Home dan Global Search.
const kAllAppFeatures = <AppFeature>[
  AppFeature('Konseling AI', 'Teman cerita virtual', Icons.auto_awesome, AppColors.primary, '/chat'),
  AppFeature('Jurnal', 'Tulis & refleksi harian', Icons.auto_stories_rounded, Color(0xFF6366F1), '/journal'),
  AppFeature('Mood Tracker', 'Pantau suasana hati', Icons.mood_rounded, Color(0xFFF59E0B), '/mood/stats'),
  AppFeature('Pernapasan', 'Latihan menenangkan', Icons.air_rounded, Color(0xFF14B8A6), '/breathing'),
  AppFeature('Musik Relaksasi', 'Dengarkan & rileks', Icons.headphones_rounded, Color(0xFF8B5CF6), '/music'),
  AppFeature('Forum', 'Diskusi komunitas', Icons.forum_rounded, Color(0xFF7C3AED), '/forum'),
  AppFeature('Cerita Inspiratif', 'Kisah dari pengguna', Icons.menu_book_rounded, Color(0xFFEC4899), '/stories'),
  AppFeature('Artikel', 'Bacaan kesehatan mental', Icons.article_rounded, Color(0xFF0EA5E9), '/articles'),
  AppFeature('Game Hub', 'XP, badge & tantangan', Icons.emoji_events_rounded, Color(0xFFF59E0B), '/gamification'),
  AppFeature('Statistik Komunitas', 'Pencapaian komunitas', Icons.insights_rounded, Color(0xFF0EA5E9), '/community'),
  AppFeature('Wellness Plan', 'Rencana harianmu', Icons.self_improvement_rounded, Color(0xFF22C55E), '/home/wellness/plan'),
  AppFeature('Mini Game', 'Mindful Runner (offline)', Icons.videogame_asset_rounded, Color(0xFF7C3AED), '/game'),
  AppFeature('Toko Hadiah', 'Tukar koin dengan hadiah', Icons.storefront_rounded, Color(0xFFF59E0B), '/rewards'),
  AppFeature('Premium', 'Buka fitur eksklusif', Icons.workspace_premium_rounded, Color(0xFFD97706), '/billing/premium'),
];
