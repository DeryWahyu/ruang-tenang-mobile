import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../common/widgets/app_bottom_sheet.dart';
import '../../common/widgets/level_badge.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/constants/app_features.dart';
import '../../common/widgets/mascot_hero.dart';
import '../widgets/home_overview_section.dart';
import '../widgets/member_feature_tour.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final userName = user?.name.split(' ').first ?? 'Sahabat';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Greeting header — scrolls naturally with the content.
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 12,
                16,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $userName!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Semoga harimu menyenangkan',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const MemberFeatureTour(),
                  _circleIconButton(
                    Icons.search_rounded,
                    () => context.push('/search'),
                  ),
                ],
              ),
            ),
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  MascotHero(
                    title: 'Selamat datang, $userName',
                    description:
                        'Kenali perasaanmu dan lanjutkan satu langkah kecil hari ini.',
                    pose: 'student-welcome',
                    eyebrow: 'Ruang untukmu',
                  ),
                  const SizedBox(height: 12),
                  _buildSupportBanner(context),
                  const SizedBox(height: 12),

                  // Gamification / XP Progress Mini
                  const _HomeXpCard(),
                  const SizedBox(height: 12),

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
                          onTap: () => context.push(
                            '/mood/stats',
                          ), // Or push to quick mood modal
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
                  const SizedBox(height: 12),

                  const HomeOverviewSection(),
                  const SizedBox(height: 12),

                  // Explore Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Eksplorasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAllFeatures(context),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal scroll for features
                  SizedBox(
                    height: 136,
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
                          route: '/community?tab=stories',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Forum',
                          subtitle: 'Diskusi komunitas',
                          icon: Icons.forum_rounded,
                          color: Colors.purple,
                          route: '/community',
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

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.foreground),
        onPressed: onTap,
      ),
    );
  }

  /// Daftar lengkap fitur aplikasi — ditampilkan dalam bottom sheet
  /// "Lihat Semua" pada section Eksplorasi. Sebelumnya ini berada di
  /// layar `/explore` terpisah; digabung ke Home agar navigasi lebih ringkas.

  /// Membuka bottom sheet berisi grid seluruh fitur aplikasi.
  void _showAllFeatures(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: 'Jelajahi Fitur',
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 130,
        ),
        itemCount: kAllAppFeatures.length,
        itemBuilder: (context, index) {
          final f = kAllAppFeatures[index];
          return _buildExploreCard(context, f);
        },
      ),
    );
  }

  /// Kartu fitur di dalam bottom sheet "Jelajahi Fitur".
  Widget _buildExploreCard(BuildContext context, AppFeature f) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).pop(); // tutup sheet sebelum berpindah
          context.push(f.route);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: f.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(f.icon, color: f.color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                f.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                f.subtitle,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSafeSupport(context),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SAFE SUPPORT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bantuan selalu dekat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jika situasi terasa tidak aman, cari dukungan cepat di sini.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSafeSupport(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MascotHero(
                title: 'Anda Tidak Sendirian',
                description:
                    'Jika merasa dalam bahaya atau ingin menyakiti diri, segera cari bantuan dari orang terdekat atau layanan darurat.',
                pose: 'heart',
              ),
              const SizedBox(height: 16),
              const Text(
                'Layanan darurat Indonesia: 119 ext 8',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse('tel:119')),
                  icon: const Icon(Icons.phone),
                  label: const Text('Hubungi 119'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Real-data XP / level mini card on the home dashboard. Pulls the user's
/// level journey (level, exp, progress) from the backend, falling back to the
/// cached auth user while loading.
class _HomeXpCard extends StatefulWidget {
  const _HomeXpCard();

  @override
  State<_HomeXpCard> createState() => _HomeXpCardState();
}

class _HomeXpCardState extends State<_HomeXpCard> {
  PersonalJourney? _journey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final journey = await sl<GamificationRepository>().getPersonalJourney();
      if (mounted) setState(() => _journey = journey);
    } catch (_) {
      // Keep auth-user fallback.
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final journey = _journey;

    final level = journey?.currentLevel ?? user?.level ?? 1;
    final exp = journey?.currentExp ?? user?.exp ?? 0;
    final badgeName = (journey != null && journey.badgeName.isNotEmpty)
        ? journey.badgeName
        : ((user?.badgeName.isNotEmpty ?? false) ? user!.badgeName : 'Pemula');
    final badgeIcon = (journey != null && journey.badgeIcon.isNotEmpty)
        ? journey.badgeIcon
        : (user?.badgeIcon ?? '');
    final progress = journey != null
        ? (journey.progressPercent / 100).clamp(0.0, 1.0)
        : null;
    final toNext = journey?.expToNextLevel ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/journey'),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: LevelBadge(icon: badgeIcon, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Level $level: $badgeName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$exp XP',
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.amber.withValues(alpha: 0.2),
                        color: Colors.amber.shade600,
                        minHeight: 6,
                      ),
                    ),
                    if (journey != null && toNext > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        '$toNext XP lagi menuju Level ${level + 1}',
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft, modern gradient backdrop is now provided globally via
/// `GradientBackground` (see app.dart builder), so the home screen no longer
/// needs its own backdrop widget.
