import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../common/widgets/mascot_hero.dart';
import '../widgets/gamification_badge_icon.dart';

class JourneySummaryScreen extends StatefulWidget {
  final bool showAppBar;
  const JourneySummaryScreen({super.key, this.showAppBar = true});

  @override
  State<JourneySummaryScreen> createState() => _JourneySummaryScreenState();
}

class _JourneySummaryScreenState extends State<JourneySummaryScreen> {
  final _repository = sl<GamificationRepository>();
  PersonalJourney? _journey;
  List<BadgeProgress> _badges = [];
  List<ExpHistory> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repository.getPersonalJourney(),
        _repository.getBadges(),
        _repository.getExpHistory(limit: 5),
      ]);
      if (!mounted) return;
      final history = results[2] as Map<String, dynamic>;
      setState(() {
        _journey = results[0] as PersonalJourney;
        _badges = results[1] as List<BadgeProgress>;
        _history = history['items'] as List<ExpHistory>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Perjalanan belum berhasil dimuat.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: widget.showAppBar
        ? AppBar(
            title: const Text(
              'Perjalananmu',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          )
        : null,
    body: _loading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : _error != null
        ? _errorView()
        : RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                const MascotHero(
                  eyebrow: 'PERJALANAN BERTUMBUH',
                  title: 'Setiap langkah berarti',
                  description:
                      'Rayakan progres kecil dan lihat sejauh mana kamu sudah bertumbuh.',
                  pose: 'tour-journey',
                  overflowMascot: true,
                ),
                const SizedBox(height: 16),
                if (_journey != null) _journeyCard(_journey!),
                if (_journey != null) ...[
                  const SizedBox(height: 14),
                  _activityStats(_journey!),
                ],
                const SizedBox(height: 24),
                _sectionHeading(
                  icon: Icons.bar_chart_rounded,
                  title: 'Jejak aktivitasmu',
                  description:
                      'Setiap aktivitas menambah pengalaman dalam perjalananmu.',
                  color: const Color(0xFF7C3AED),
                  background: const Color(0xFFF5F3FF),
                ),
                const SizedBox(height: 10),
                _historyCard(),
                const SizedBox(height: 24),
                _sectionHeading(
                  icon: Icons.emoji_events_rounded,
                  title: 'Galeri pencapaian',
                  description:
                      'Badge menjadi penanda momen penting yang sudah kamu capai.',
                  color: const Color(0xFFB45309),
                  background: const Color(0xFFFFF7ED),
                ),
                const SizedBox(height: 10),
                _badgeGallery(),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => context.push('/gamification/daily-tasks'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.red200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.task_alt_rounded),
                  label: const Text('Lihat misi harian'),
                ),
              ],
            ),
          ),
  );

  Widget _errorView() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: Image.asset(
              'assets/images/mascot/map.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Perjalanan belum berhasil dimuat.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _load,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );

  Widget _journeyCard(PersonalJourney journey) {
    final progress = (journey.progressPercent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1F2), Colors.white, Color(0xFFFFF8F0)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF4D8D9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x150F172A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFF59E0B),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.badgeName.isEmpty
                          ? 'Penjelajah Baru'
                          : journey.badgeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${journey.currentLevel} · Tier ${journey.tierName}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.foreground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lv.${journey.currentLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MENUJU LEVEL BERIKUTNYA',
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journey.expToNextLevel > 0
                                ? '${journey.expToNextLevel} XP lagi'
                                : 'Level maksimum tercapai',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${journey.currentExp} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: AppColors.gray100,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progres ${journey.progressPercent.round()}%',
                        style: const TextStyle(
                          color: AppColors.gray600,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFF59E0B),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${journey.newBadgesCount} badge baru',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/journey?tab=map'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Lanjutkan perjalanan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/journey?tab=rewards'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: const Color(0xFFB45309),
                    side: const BorderSide(color: Color(0xFFFCD34D)),
                    backgroundColor: const Color(0xFFFFFBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                  label: const Text('Lihat hadiah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityStats(PersonalJourney journey) {
    final stats = [
      (
        Icons.local_fire_department_rounded,
        '${journey.currentStreak} hari',
        'Streak sekarang',
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
      ),
      (
        Icons.flag_rounded,
        '${journey.longestStreak} hari',
        'Streak terbaik',
        const Color(0xFF0284C7),
        const Color(0xFFF0F9FF),
      ),
      (
        Icons.trending_up_rounded,
        '+${journey.monthlyXp}',
        'XP bulan ini',
        const Color(0xFF059669),
        const Color(0xFFECFDF5),
      ),
      (
        Icons.bolt_rounded,
        '${journey.totalActivities}',
        'Total aktivitas',
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 84,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _MetricCard(
          icon: stat.$1,
          value: stat.$2,
          label: stat.$3,
          color: stat.$4,
          background: stat.$5,
        );
      },
    );
  }

  Widget _sectionHeading({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color background,
  }) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _historyCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        if (_history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Aktivitas baru akan muncul di sini.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
            ),
          )
        else
          ..._history.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    item.description.isEmpty
                        ? item.activityType
                        : item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  trailing: Text(
                    '+${item.points} XP',
                    style: const TextStyle(
                      color: Color(0xFF6D28D9),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (index < _history.length - 1)
                  const Divider(height: 1, indent: 48),
              ],
            );
          }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.push('/gamification/exp-history'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            icon: const Icon(Icons.history_rounded, size: 17),
            label: const Text('Lihat riwayat XP'),
          ),
        ),
      ],
    ),
  );

  Widget _badgeGallery() {
    final badges = [..._badges]
      ..sort((a, b) => (b.earned ? 1 : 0).compareTo(a.earned ? 1 : 0));
    final earnedCount = badges.where((badge) => badge.earned).length;
    final progress = badges.isEmpty ? 0.0 : earnedCount / badges.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: AppColors.gray200,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFD97706),
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koleksi badge',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$earnedCount dari ${badges.length} diraih',
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Teruskan kebiasaan baik untuk membuka badge.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Progres koleksi',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (badges.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Pencapaian akan muncul saat kamu menyelesaikan target.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length < 4 ? badges.length : 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 126,
              ),
              itemBuilder: (context, index) => _badgeTile(badges[index]),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/gamification/badges'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              icon: const Icon(Icons.workspace_premium_rounded, size: 17),
              label: const Text('Lihat semua badge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(BadgeProgress badge) {
    final earned = badge.earned;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: earned
            ? const Color(0xFFFFFBEB).withValues(alpha: 0.65)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? const Color(0xFFFDE68A) : AppColors.gray200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned ? const Color(0xFFFFF8E8) : AppColors.gray100,
              border: Border.all(
                color: earned ? const Color(0xFFFCD34D) : AppColors.gray300,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: GamificationBadgeIcon(
              badgeKey: badge.badgeKey,
              category: badge.category,
              earned: earned,
              size: 38,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            badge.badgeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: earned ? AppColors.foreground : AppColors.mutedForeground,
              fontSize: 11,
              fontWeight: earned ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _badgeCategoryLabel(badge.category),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  String _badgeCategoryLabel(String category) {
    final words = category.trim().replaceAll('_', ' ').split(' ');
    return words
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 9,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
