import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/wellness_bloc.dart';
import '../bloc/wellness_event.dart';
import '../bloc/wellness_state.dart';

class WellnessPlanScreen extends StatelessWidget {
  const WellnessPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WellnessBloc>()..add(const WellnessPlanRequested()),
      child: const _WellnessPlanView(),
    );
  }
}

class _WellnessPlanView extends StatelessWidget {
  const _WellnessPlanView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Wellness'),
        centerTitle: true,
      ),
      body: BlocBuilder<WellnessBloc, WellnessState>(
        builder: (context, state) {
          if (state.status == WellnessStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == WellnessStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WellnessBloc>().add(const WellnessPlanRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state.plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Belum ada rencana wellness.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/wellness/onboarding'),
                    child: const Text('Mulai Personalisasi'),
                  ),
                ],
              ),
            );
          }

          final plan = state.plan!;
          return RefreshIndicator(
            onRefresh: () async => context.read<WellnessBloc>().add(const WellnessPlanRequested()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.red400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(plan.summary, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('${plan.completionPercent}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: plan.completionPercent / 100,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Tugas Wellness Anda', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...plan.items.map((item) {
                  final isCompleted = item.status == 'completed';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: isCompleted ? null : () => _handleItemTap(context, item.route),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.successLight : AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : _getIconForAction(item.actionType),
                          color: isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                      subtitle: Text(item.description, style: const TextStyle(fontSize: 12)),
                      trailing: isCompleted ? const Text('Selesai', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)) : IconButton(
                        icon: const Icon(Icons.radio_button_unchecked, color: AppColors.mutedForeground),
                        onPressed: () {
                          context.read<WellnessBloc>().add(WellnessPlanItemCompleted(item.id));
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForAction(String type) {
    switch (type) {
      case 'journal': return Icons.book;
      case 'breathing': return Icons.air;
      case 'music': return Icons.music_note;
      case 'chat': return Icons.chat;
      default: return Icons.task_alt;
    }
  }

  void _handleItemTap(BuildContext context, String route) {
    if (route.isNotEmpty && route != '#') {
      // route examples: /journal/new, /breathing, /chat/new
      if (route.startsWith('/')) {
        context.push(route);
      }
    }
  }
}