import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../common/widgets/mascot_hero.dart';

class JourneySummaryScreen extends StatefulWidget {
  const JourneySummaryScreen({super.key});
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
      final journey = await _repository.getPersonalJourney();
      final badges = await _repository.getBadges();
      final history = await _repository.getExpHistory(limit: 5);
      if (!mounted) return;
      setState(() {
        _journey = journey;
        _badges = badges;
        _history = history['items'] as List<ExpHistory>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Perjalanan belum berhasil dimuat.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Perjalananmu')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: TextButton(
              onPressed: _load,
              child: Text('$_error Coba lagi'),
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const MascotHero(
                  title: 'Setiap langkah berarti',
                  description:
                      'Lihat pertumbuhanmu dan rayakan pencapaian kecil.',
                  pose: 'map',
                ),
                const SizedBox(height: 16),
                if (_journey != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${_journey!.currentLevel} · ${_journey!.tierName}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(_journey!.badgeName),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (_journey!.progressPercent / 100)
                                .clamp(0.0, 1.0)
                                .toDouble(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_journey!.currentExp} XP · ${_journey!.expToNextLevel} XP lagi ke level berikutnya',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                label: const Text('Lihat peta'),
                                onPressed: () => context.go('/journey?tab=map'),
                              ),
                              ActionChip(
                                label: const Text('Lihat hadiah'),
                                onPressed: () =>
                                    context.go('/journey?tab=rewards'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Jejak aktivitasmu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_journey != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('${_journey!.monthlyXp} XP bulan ini')),
                      Chip(
                        label: Text(
                          '${_journey!.monthlyActivities} aktivitas bulan ini',
                        ),
                      ),
                      Chip(
                        label: Text('${_journey!.currentStreak} hari beruntun'),
                      ),
                    ],
                  ),
                ..._history.map(
                  (item) => ListTile(
                    title: Text(
                      item.description.isEmpty
                          ? item.activityType
                          : item.description,
                    ),
                    trailing: Text('+${item.points} XP'),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/gamification/exp-history'),
                  child: const Text('Lihat riwayat XP'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Galeri pencapaian',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_badges.isEmpty)
                  const ListTile(
                    title: Text('Pencapaian akan muncul di sini.'),
                  ),
                ..._badges
                    .take(5)
                    .map(
                      (badge) => ListTile(
                        leading: Icon(
                          badge.earned
                              ? Icons.workspace_premium
                              : Icons.workspace_premium_outlined,
                        ),
                        title: Text(badge.badgeName),
                        subtitle: Text(badge.description),
                      ),
                    ),
                TextButton(
                  onPressed: () => context.push('/gamification/badges'),
                  child: const Text('Lihat semua badge'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/gamification/daily-tasks'),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Misi harian'),
                ),
              ],
            ),
          ),
  );
}
