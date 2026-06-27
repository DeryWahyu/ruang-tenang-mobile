import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final userName = user?.name.split(' ').first ?? 'Sahabat';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
              title: Text(
                'Halo, $userName! ✨',
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, color: AppColors.foreground),
                  onPressed: () => context.push('/search'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.foreground),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Wellness Banner (Primary Call to Action)
                  _buildWellnessBanner(context),
                  const SizedBox(height: 24),

                  // Gamification / XP Progress Mini
                  _buildGamificationWidget(context),
                  const SizedBox(height: 24),

                  // Quick Actions Grid (Mood & Journal)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardCard(
                          context,
                          title: 'Catat Mood',
                          subtitle: 'Bagaimana perasaanmu?',
                          icon: Icons.emoji_emotions_rounded,
                          color: Colors.orange,
                          onTap: () => context.push('/mood/stats'), // Or push to quick mood modal
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDashboardCard(
                          context,
                          title: 'Jurnal Cepat',
                          subtitle: 'Tulis ceritamu',
                          icon: Icons.edit_document,
                          color: AppColors.primary,
                          onTap: () => context.push('/journal/create'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Breathing / Meditation Widget
                  _buildBreathingWidget(context),
                  const SizedBox(height: 24),

                  // Music / Relaxation Widget
                  _buildMusicWidget(context),
                  const SizedBox(height: 32),

                  // Explore Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Eksplorasi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      TextButton(
                        onPressed: () => context.push('/articles'),
                        child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Horizontal scroll for features
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildFeatureCard(
                          context, 
                          title: 'Artikel', 
                          subtitle: 'Bacaan untuk sehat mental',
                          icon: Icons.article_rounded, 
                          color: Colors.teal, 
                          route: '/articles',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context, 
                          title: 'Cerita', 
                          subtitle: 'Kisah inspiratif pengguna',
                          icon: Icons.auto_stories_rounded, 
                          color: Colors.indigo, 
                          route: '/stories',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context, 
                          title: 'Forum', 
                          subtitle: 'Diskusi komunitas',
                          icon: Icons.forum_rounded, 
                          color: Colors.purple, 
                          route: '/forum',
                        ),
                      ],
                    ),
                  ),

                  // Extra padding at bottom for navbar clearance
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/wellness/plan'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Text('Rencana Harian', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Wellness Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text('Selesaikan misimu hari ini untuk menjaga kesehatan mental.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.self_improvement_rounded, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGamificationWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => context.push('/gamification'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Level 3: Penjelajah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('450 XP', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      color: Colors.amber,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Sangat soft teal/green
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/breathing'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.air_rounded, color: Colors.teal, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sesi Pernapasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                      SizedBox(height: 4),
                      Text('Ambil jeda sejenak untuk menenangkan pikiranmu.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/music'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('Audio Relaksasi', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Dengarkan Musik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('Temukan kedamaian lewat alunan nada.', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String route}) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
