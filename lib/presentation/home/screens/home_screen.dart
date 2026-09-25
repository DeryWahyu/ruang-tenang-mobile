import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../common/widgets/app_bottom_sheet.dart';
import '../../common/widgets/level_badge.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/constants/app_features.dart';
import '../widgets/home_overview_section.dart';

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

                  _buildWelcomeHero(userName),
                  const SizedBox(height: 12),

                  // Gamification / XP Progress Mini
                  const _HomeXpCard(),
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.swipe_rounded,
                          size: 16,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Geser ke samping untuk melihat fitur lainnya',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  // Horizontal scroll for features
                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Statistik Mood',
                          subtitle: 'Lihat pola perasaanmu',
                          icon: Icons.mood_rounded,
                          color: const Color(0xFFE89A3C),
                          mascotPath: 'assets/images/mascot/tour-mood.webp',
                          route: '/mood/stats',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Artikel',
                          subtitle: 'Bacaan untuk sehat mental',
                          icon: Icons.article_rounded,
                          color: Colors.teal,
                          mascotPath: 'assets/images/mascot/home-artikel.webp',
                          route: '/articles',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Cerita',
                          subtitle: 'Kisah inspiratif pengguna',
                          icon: Icons.auto_stories_rounded,
                          color: Colors.indigo,
                          mascotPath: 'assets/images/mascot/home-cerita.webp',
                          route: '/community?tab=stories',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Forum',
                          subtitle: 'Diskusi komunitas',
                          icon: Icons.forum_rounded,
                          color: Colors.purple,
                          mascotPath: 'assets/images/mascot/home-forum.webp',
                          route: '/community',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Perjalanan',
                          subtitle: 'Level, EXP, dan hadiahmu',
                          icon: Icons.map_rounded,
                          color: const Color(0xFFD97706),
                          mascotPath: 'assets/images/mascot/tour-journey.webp',
                          route: '/journey',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureCard(
                          context,
                          title: 'Koleksi Badge',
                          subtitle: 'Rayakan pencapaian kecilmu',
                          icon: Icons.emoji_events_rounded,
                          color: const Color(0xFFB45309),
                          mascotPath: 'assets/images/mascot/trophy.webp',
                          route: '/gamification/badges',
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

  Widget _buildWelcomeHero(String userName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = constraints.maxWidth < 330 ? 126.0 : 146.0;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 166),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF7F4), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.red700.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 12,
                bottom: 4,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.red100.withValues(alpha: 0.72),
                        AppColors.red100.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 18, imageWidth * 0.7 + 16, 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ruang untukmu',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Selamat datang, $userName',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Kenali perasaanmu dan lanjutkan satu langkah kecil hari ini.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -8,
                bottom: -12,
                width: imageWidth,
                height: 178,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/mascot/student-welcome.webp',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String mascotPath,
    required String route,
  }) {
    return SizedBox(
      width: 236,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.card,
                    Color.lerp(AppColors.card, color, 0.055)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(route),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 104, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: color.withValues(alpha: 0.82),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 14,
            width: 74,
            height: 74,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.16),
                      color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -8,
            width: 116,
            height: 154,
            child: IgnorePointer(
              child: Image.asset(
                mascotPath,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
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
