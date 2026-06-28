import 'package:flutter/material.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
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
    try {
      await _moodRepository.record(mood);
      if (mounted) Navigator.of(dialogContext).pop();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Mood berhasil dicatat! Semoga harimu menyenangkan 😊'),
            backgroundColor: AppColors.success,
          ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Text('👋', style: TextStyle(fontSize: 30))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: MoodType.values.map((m) {
                              return SizedBox(
                                width: 88,
                                height: 88,
                                child: Material(
                                  color: AppColors.muted.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: _submitting ? null : () => _record(dialogContext, m),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(m.emoji, style: const TextStyle(fontSize: 30)),
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
                          const Text('Rekomendasi konten akan disesuaikan dengan mood-mu ✨',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                        ],
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
