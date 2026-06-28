import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/breathing.dart';
import '../bloc/breathing_bloc.dart';
import '../bloc/breathing_event.dart';
import '../bloc/breathing_state.dart';

class BreathingListScreen extends StatelessWidget {
  const BreathingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BreathingBloc>()
        ..add(const BreathingTechniquesRequested())
        ..add(const BreathingStatsRequested()),
      child: const _BreathingListView(),
    );
  }
}

class _BreathingListView extends StatelessWidget {
  const _BreathingListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Pernapasan'),
        centerTitle: true,
      ),
      body: BlocBuilder<BreathingBloc, BreathingState>(
        builder: (context, state) {
          if (state.status == BreathingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == BreathingStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BreathingBloc>().add(const BreathingTechniquesRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BreathingBloc>().add(const BreathingTechniquesRequested());
              context.read<BreathingBloc>().add(const BreathingStatsRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.stats != null) _buildStatsCard(context, state.stats!),
                const SizedBox(height: 20),
                Text('Pilih Teknik', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...state.techniques.map((technique) => _buildTechniqueCard(context, technique)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, BreathingStats stats) {
    return Container(
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
          Text('Statistik Pernapasan', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(context, '${stats.overall.totalSessions}', 'Total Sesi'),
              _statItem(context, '${stats.overall.totalMinutes}', 'Total Menit'),
              _statItem(context, '${stats.streakInfo.currentStreak}', 'Hari Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildTechniqueCard(BuildContext context, BreathingTechnique technique) {
    final colorMap = {
      'blue': Colors.blue,
      'green': Colors.green,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'red': AppColors.primary,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
    };
    final color = colorMap[technique.color.toLowerCase()] ?? AppColors.primary;
    final iconMap = {
      'wind': Icons.air,
      'box': Icons.crop_square,
      'lungs': Icons.favorite,
      'leaf': Icons.eco,
      'moon': Icons.nightlight_round,
      'sun': Icons.wb_sunny,
      'wave': Icons.waves,
      'brain': Icons.psychology,
    };
    final icon = iconMap[technique.icon.toLowerCase()] ?? Icons.air;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/breathing/session', extra: technique),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.65)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(technique.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        technique.bestFor.isNotEmpty ? technique.bestFor : technique.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _timingChip('Tarik ${technique.inhaleDuration}s', color),
                          if (technique.inhaleHoldDuration > 0)
                            _timingChip('Tahan ${technique.inhaleHoldDuration}s', color),
                          _timingChip('Buang ${technique.exhaleDuration}s', color),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timingChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}