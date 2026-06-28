import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/mood.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';
import '../widgets/mood_picker.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  MoodType? _selectedMood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodBloc>().add(const MoodTodayRequested());
    });
  }

  void _onSave() {
    if (_selectedMood != null) {
      context.read<MoodBloc>().add(MoodRecordRequested(_selectedMood!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MoodBloc, MoodState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == MoodStatus.recorded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood berhasil disimpan! Terima kasih sudah berbagi.'),
              backgroundColor: AppColors.primary,
            ),
          );
          // Pop the screen after successful save
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.pop();
          });
        } else if (state.status == MoodStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.destructive),
          );
        }
      },
      builder: (context, state) {
        final hasCheckedToday = (state.today ?? const TodayMood()).hasChecked;
        final savedMood = (state.today ?? const TodayMood()).mood?.mood;
        
        // Auto-select if already saved today
        if (hasCheckedToday && savedMood != null && _selectedMood == null) {
          _selectedMood = savedMood;
        }

        final canSave = _selectedMood != null && (!hasCheckedToday || _selectedMood != savedMood);
        final isLoading = state.status == MoodStatus.recording || state.status == MoodStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.foreground),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_rounded, color: AppColors.primary),
                tooltip: 'Statistik Mood',
                onPressed: () => context.push('/mood/stats'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Bagaimana perasaanmu\nhari ini?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasCheckedToday 
                        ? 'Kamu sudah mencatat mood hari ini. Merasa berbeda?' 
                        : 'Pilih satu ikon yang paling mewakili kondisimu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.mutedForeground.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Central Picker Grid
                  Expanded(
                    child: MoodPicker(
                      selectedMood: _selectedMood,
                      onMoodSelected: (mood) {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                      isGrid: true,
                    ),
                  ),

                  // Bottom Action
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canSave && !isLoading ? _onSave : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.muted,
                          elevation: canSave ? 8 : 0,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Text(
                                hasCheckedToday ? 'Perbarui Mood' : 'Simpan Mood',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
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
  }
}
