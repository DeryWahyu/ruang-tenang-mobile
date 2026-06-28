import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class ProgressMapScreen extends StatelessWidget {
  const ProgressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationProgressMapRequested()),
      child: const _ProgressMapView(),
    );
  }
}

class _ProgressMapView extends StatelessWidget {
  const _ProgressMapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Peta Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listenWhen: (p, c) => p.successMessage != c.successMessage || p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.successMessage.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.successMessage), backgroundColor: AppColors.success));
          } else if (state.errorMessage.isNotEmpty && state.status == GamificationStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.destructive));
          }
        },
        builder: (context, state) {
          if (state.progressMap == null && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final map = state.progressMap;
          if (map == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage.isEmpty ? 'Gagal memuat peta' : state.errorMessage,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GamificationBloc>().add(const GamificationProgressMapRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<GamificationBloc>().add(const GamificationProgressMapRequested()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _overallCard(map),
                const SizedBox(height: 20),
                ...map.regions.map((r) => _regionCard(context, r)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _overallCard(ProgressMap map) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.indigo.shade400]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perjalanan Kesehatan Mentalmu',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (map.overallProgress / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${map.overallProgress.toStringAsFixed(0)}% • ${map.unlockedRegions}/${map.totalRegions} wilayah • ${map.unlockedLandmarks}/${map.totalLandmarks} landmark',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _regionCard(BuildContext context, MapRegion region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: region.isUnlocked ? AppColors.info.withOpacity(0.12) : AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: region.isUnlocked
                  ? Text(region.icon, style: const TextStyle(fontSize: 22))
                  : const Icon(Icons.lock_outline_rounded, color: AppColors.mutedForeground),
            ),
          ),
          title: Text(region.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text('${region.unlockedLandmarks}/${region.totalLandmarks} landmark terbuka',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          children: region.landmarks.map((l) => _landmarkTile(context, l)).toList(),
        ),
      ),
    );
  }

  Widget _landmarkTile(BuildContext context, MapLandmark l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Opacity(
            opacity: l.isUnlocked ? 1 : 0.4,
            child: Text(l.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                if (!l.isUnlocked) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (l.progressPercent / 100).clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.muted,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${l.currentValue}/${l.unlockValue}',
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                ] else
                  Text('+${l.xpReward} XP • +${l.coinReward} koin',
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _landmarkTrailing(context, l),
        ],
      ),
    );
  }

  Widget _landmarkTrailing(BuildContext context, MapLandmark l) {
    if (l.canClaim) {
      return GestureDetector(
        onTap: () => context.read<GamificationBloc>().add(GamificationLandmarkClaimed(l.id)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Klaim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    }
    if (l.isUnlocked) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success);
    }
    return const Icon(Icons.lock_outline_rounded, color: AppColors.mutedForeground, size: 20);
  }
}
