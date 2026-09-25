import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
import '../../../domain/repositories/mood_repository.dart';

/// Checks whether the user has logged their mood today and, if not, shows a
/// one-per-day mood check-in dialog — mirroring the web `MoodCheckinProvider`.
///
/// Renders nothing itself; it only orchestrates the dialog.
class MoodCheckinGate extends StatefulWidget {
  const MoodCheckinGate({super.key});

  @override
  State<MoodCheckinGate> createState() => _MoodCheckinGateState();
}

class _MoodCheckinGateState extends State<MoodCheckinGate> {
  final MoodRepository _moodRepository = sl<MoodRepository>();
  bool _checked = false;
  bool _submitting = false;
  MoodType? _selectedMood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTodayMood());
  }

  Future<void> _checkTodayMood() async {
    if (_checked || !mounted) return;
    _checked = true;
    try {
      final today = await _moodRepository.today();
      if (!today.hasChecked && mounted) {
        _showMoodDialog();
      }
    } catch (_) {
      // Silently ignore — mood check-in is non-critical.
    }
  }

  Future<void> _record(
    BuildContext dialogContext,
    MoodType mood,
    StateSetter setDialogState,
  ) async {
    if (_submitting) return;
    _submitting = true;
    _selectedMood = mood;
    setDialogState(() {});

    final navigator = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _moodRepository.record(mood);
      if (mounted && navigator.mounted) navigator.pop();
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Mood berhasil dicatat! Semoga harimu menyenangkan',
              ),
              backgroundColor: AppColors.success,
            ),
          );
      }
    } catch (_) {
      if (navigator.mounted) {
        setDialogState(() {
          _submitting = false;
          _selectedMood = null;
        });
      }
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Gagal mencatat mood'),
              backgroundColor: AppColors.destructive,
            ),
          );
      }
    } finally {
      _submitting = false;
    }
  }

  void _showMoodDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF202238).withValues(alpha: 0.2),
                        blurRadius: 42,
                        offset: const Offset(0, 22),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHero(),
                          _buildMoodOptions(dialogContext, setDialogState),
                        ],
                      ),
                      Positioned(
                        top: 2,
                        right: -2,
                        width: 154,
                        height: 210,
                        child: IgnorePointer(
                          child: Image.asset(
                            'assets/images/mascot/checkin.webp',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF4EF), Color(0xFFFFE4DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 18,
            bottom: -10,
            child: Container(
              width: 138,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 116, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: AppColors.red700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CHECK-IN HARIAN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.red700,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.05,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Halo, Apa Kabar?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF26304A),
                    fontSize: 23,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.65,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pelan-pelan, pilih perasaan yang paling dekat denganmu hari ini.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF596477),
                    height: 1.45,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOptions(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Apa yang kamu rasakan?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Semua perasaan punya ruang di sini.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.gray500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 9.0;
              final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;
              final tileSize = math.min(itemWidth, 104.0).toDouble();

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: MoodType.values
                    .map(
                      (mood) => _buildMoodTile(
                        mood,
                        tileSize,
                        dialogContext,
                        setDialogState,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Rekomendasi untukmu akan mengikuti perasaan yang kamu catat.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.gray500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTile(
    MoodType mood,
    double tileSize,
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) {
    final isSelected = _selectedMood == mood;
    final isBusy = _submitting && isSelected;

    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Semantics(
        selected: isSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [const Color(0xFFFFF2EF), const Color(0xFFFFE9E5)]
                  : [Colors.white, const Color(0xFFFAFAFD)],
            ),
            border: Border.all(
              color: isSelected ? AppColors.red300 : const Color(0xFFE8EAF0),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submitting
                  ? null
                  : () => _record(dialogContext, mood, setDialogState),
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          mood.activeImagePath,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          mood.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: const Color(0xFF596477),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isBusy)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                          semanticsLabel: 'Mencatat perasaan ${mood.label}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
