import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';

class MemberFeatureTour extends StatefulWidget {
  const MemberFeatureTour({super.key});
  @override
  State<MemberFeatureTour> createState() => _MemberFeatureTourState();
}

class _TourStep {
  final String title;
  final String description;
  final String pose;
  final String route;
  const _TourStep(this.title, this.description, this.pose, this.route);
}

const _steps = <_TourStep>[
  _TourStep(
    'Halo, aku RuNa!',
    'Beranda mengumpulkan langkah kecilmu setiap hari.',
    'guide',
    '/home',
  ),
  _TourStep(
    'Kenali suasana hatimu',
    'Lihat pola mood dan catat apa yang kamu rasakan.',
    'mood',
    '/mood/stats',
  ),
  _TourStep(
    'Bantuan selalu dekat',
    'Gunakan bantuan cepat saat kamu sedang merasa tidak aman.',
    'support',
    '/home',
  ),
  _TourStep(
    'Ceritakan dengan caramu',
    'Tulis atau ucapkan hal yang ingin kamu bagikan ke Teman Cerita AI.',
    'chat',
    '/chat',
  ),
  _TourStep(
    'Simpan refleksimu',
    'Tulis jurnal dan lihat kembali catatan pribadimu.',
    'journal',
    '/journal',
  ),
  _TourStep(
    'Temukan bacaan',
    'Cari artikel atau tulis artikelmu sendiri.',
    'articles',
    '/articles',
  ),
  _TourStep(
    'Pilih irama pendamping',
    'Dengarkan musik dan susun playlist.',
    'music',
    '/music',
  ),
  _TourStep(
    'Terhubung dengan sesama',
    'Jelajahi forum, kisah, dan jurnal publik.',
    'community',
    '/community',
  ),
  _TourStep(
    'Lihat perjalananmu',
    'Ringkasan, peta, dan hadiah ada di sini.',
    'journey',
    '/journey',
  ),
  _TourStep(
    'Satu langkah kecil lagi',
    'Buka misi harian untuk merayakan kemajuanmu.',
    'missions',
    '/journey',
  ),
];

class _MemberFeatureTourState extends State<MemberFeatureTour> {
  final _api = sl<ApiClient>();
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '${ApiConstants.wellness}/onboarding',
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final profile = response.data?['profile'];
      if (!mounted ||
          _shown ||
          profile is! Map ||
          profile['tour_completed_at'] != null) {
        return;
      }
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    } catch (_) {
      /* The tour can still be opened manually. */
    }
  }

  Future<void> _complete() async {
    try {
      await _api.post<dynamic>('${ApiConstants.wellness}/tour/complete');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Status tur belum tersimpan. Kamu bisa mencobanya lagi.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _open() async {
    var index = 0;
    final route = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) {
          final step = _steps[index];
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext, ''),
                      child: const Text('Lewati'),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: Image.asset(
                      'assets/images/mascot/tour-${step.pose}.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    '${index + 1} / ${_steps.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(step.description, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (index > 0)
                        TextButton(
                          onPressed: () => update(() => index--),
                          child: const Text('Kembali'),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (index == _steps.length - 1) {
                            Navigator.pop(dialogContext, step.route);
                          } else {
                            update(() => index++);
                          }
                        },
                        child: Text(
                          index == _steps.length - 1 ? 'Selesai' : 'Lanjut',
                        ),
                      ),
                    ],
                  ),
                  if (index > 0 && index < _steps.length - 1)
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, step.route),
                      child: const Text('Buka fitur ini'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (!mounted) return;
    await _complete();
    if (!mounted) return;
    if (route != null && route.isNotEmpty) context.push(route);
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Tur RuNa',
    icon: const Icon(Icons.explore_outlined),
    onPressed: _open,
  );
}
