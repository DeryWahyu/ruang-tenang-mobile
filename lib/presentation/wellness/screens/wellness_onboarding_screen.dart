import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/wellness_bloc.dart';
import '../bloc/wellness_event.dart';
import '../bloc/wellness_state.dart';

class WellnessOnboardingScreen extends StatefulWidget {
  const WellnessOnboardingScreen({super.key});

  @override
  State<WellnessOnboardingScreen> createState() => _WellnessOnboardingScreenState();
}

class _WellnessOnboardingScreenState extends State<WellnessOnboardingScreen> {
  int _currentStep = 0;
  String _selectedMood = '';
  final List<String> _selectedGoals = [];
  final List<String> _selectedHabits = [];

  final List<String> _moodOptions = ['Senang', 'Biasa Saja', 'Cemas', 'Sedih', 'Stres', 'Lelah'];
  final List<String> _goalOptions = ['Mengurangi kecemasan', 'Meningkatkan kualitas tidur', 'Membangun kebiasaan baik', 'Lebih fokus', 'Mengelola stres', 'Meningkatkan kebahagiaan'];
  final List<String> _habitOptions = ['Olahraga teratur', 'Makan sehat', 'Tidur cukup', 'Meditasi', 'Menulis jurnal', 'Membaca buku'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WellnessBloc>(),
      child: BlocConsumer<WellnessBloc, WellnessState>(
        listener: (context, state) {
          if (state.status == WellnessStatus.success && state.plan != null) {
            context.go('/wellness/plan'); // Redirect to plan once generated
          } else if (state.status == WellnessStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Personalisasi Wellness'),
              leading: _currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentStep--)) : null,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(value: (_currentStep + 1) / 3, backgroundColor: AppColors.muted),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStep(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _canProceed() 
                          ? () {
                              if (_currentStep < 2) {
                                setState(() => _currentStep++);
                              } else {
                                context.read<WellnessBloc>().add(
                                  WellnessOnboardingSubmitted(
                                    initialMood: _selectedMood,
                                    goals: _selectedGoals,
                                    habits: _selectedHabits,
                                  ),
                                );
                              }
                            }
                          : null,
                        child: state.status == WellnessStatus.submitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_currentStep < 2 ? 'Selanjutnya' : 'Selesai'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _canProceed() {
    if (_currentStep == 0) return _selectedMood.isNotEmpty;
    if (_currentStep == 1) return _selectedGoals.isNotEmpty;
    return true; // habits are optional
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bagaimana perasaanmu belakangan ini?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pilih satu yang paling menggambarkan keadaanmu.', style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _moodOptions.map((mood) => ChoiceChip(
              label: Text(mood),
              selected: _selectedMood == mood,
              onSelected: (selected) => setState(() => _selectedMood = selected ? mood : ''),
            )).toList(),
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apa tujuan utamamu?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pilih 1-3 tujuan yang ingin kamu capai.', style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _goalOptions.map((goal) => FilterChip(
              label: Text(goal),
              selected: _selectedGoals.contains(goal),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_selectedGoals.length < 3) _selectedGoals.add(goal);
                  } else {
                    _selectedGoals.remove(goal);
                  }
                });
              },
            )).toList(),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kebiasaan apa yang sudah kamu lakukan?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pilih kebiasaan yang rutin kamu jalani. (Opsional)', style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _habitOptions.map((habit) => FilterChip(
              label: Text(habit),
              selected: _selectedHabits.contains(habit),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedHabits.add(habit);
                  } else {
                    _selectedHabits.remove(habit);
                  }
                });
              },
            )).toList(),
          ),
        ],
      );
    }
  }
}