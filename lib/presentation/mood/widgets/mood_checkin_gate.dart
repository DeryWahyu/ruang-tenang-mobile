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

  Future<void> _record(BuildContext dialogContext, MoodType mood) async {
    if (_submitting) return;
    _submitting = true;
    // Tangkap referensi sebelum await agar tidak memakai BuildContext
    // melintasi async gap (aman terhadap widget yang sudah dispose).
    final navigator = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _moodRepository.record(mood);
      if (mounted) navigator.pop();
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Mood berhasil dicatat! Semoga harimu menyenangkan'),
            backgroundColor: AppColors.success,
          ));
      }
    } catch (_) {
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Gagal mencatat mood'),
            backgroundColor: AppColors.destructive,
          ));
      }
    } finally {
      _submitting = false;
    }
  }

  void _showMoodDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.red600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Icon(Icons.waving_hand_rounded, color: Colors.white, size: 30)),
                          ),
                          const SizedBox(height: 12),
                          const Text('Halo, Apa Kabar?',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Yuk catat perasaanmu hari ini',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    // Mood grid
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 10.0;
                          const crossAxisCount = 3;
                          final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                          return Column(
                            children: [
                              Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                alignment: WrapAlignment.center,
                                children: MoodType.values.map((m) {
                                  return SizedBox(
                                    width: itemWidth,
                                    height: itemWidth,
                                    child: Material(
                                      color: AppColors.muted.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        onTap: _submitting ? null : () => _record(dialogContext, m),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                m.activeImagePath,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(m.label,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.mutedForeground)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                              const Text('Rekomendasi konten akan disesuaikan dengan mood-mu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
