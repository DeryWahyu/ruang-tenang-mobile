import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  const _Feature(this.title, this.subtitle, this.icon, this.color, this.route);
}

/// Shows every feature/menu available in the app in one place.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _features = <_Feature>[
    _Feature('Konseling AI', 'Teman cerita virtual', Icons.auto_awesome, AppColors.primary, '/chat'),
    _Feature('Jurnal', 'Tulis & refleksi harian', Icons.auto_stories_rounded, Color(0xFF6366F1), '/journal'),
    _Feature('Mood Tracker', 'Pantau suasana hati', Icons.mood_rounded, Color(0xFFF59E0B), '/mood/stats'),
    _Feature('Pernapasan', 'Latihan menenangkan', Icons.air_rounded, Color(0xFF14B8A6), '/breathing'),
    _Feature('Musik Relaksasi', 'Dengarkan & rileks', Icons.headphones_rounded, Color(0xFF8B5CF6), '/music'),
    _Feature('Forum', 'Diskusi komunitas', Icons.forum_rounded, Color(0xFF7C3AED), '/forum'),
    _Feature('Cerita Inspiratif', 'Kisah dari pengguna', Icons.menu_book_rounded, Color(0xFFEC4899), '/stories'),
    _Feature('Artikel', 'Bacaan kesehatan mental', Icons.article_rounded, Color(0xFF0EA5E9), '/articles'),
    _Feature('Game Hub', 'XP, badge & tantangan', Icons.emoji_events_rounded, Color(0xFFF59E0B), '/gamification'),
    _Feature('Wellness Plan', 'Rencana harianmu', Icons.self_improvement_rounded, Color(0xFF22C55E), '/wellness/plan'),
    _Feature('Pencarian', 'Cari apa saja', Icons.search_rounded, Color(0xFF64748B), '/search'),
    _Feature('Premium', 'Buka fitur eksklusif', Icons.workspace_premium_rounded, Color(0xFFD97706), '/billing/premium'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Jelajahi Fitur', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) => _card(context, _features[index]),
      ),
    );
  }

  Widget _card(BuildContext context, _Feature f) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push(f.route),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [f.color, f.color.withOpacity(0.65)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: f.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Icon(f.icon, color: Colors.white, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(f.subtitle,
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
