import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class ChestScreen extends StatelessWidget {
  const ChestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationChestsRequested()),
      child: const _ChestView(),
    );
  }
}

class _ChestView extends StatelessWidget {
  const _ChestView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peti Misteri'),
        centerTitle: true,
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listener: (context, state) {
          if (state.openChestResult != null) {
            _showRewardDialog(context, state.openChestResult!);
          }
        },
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final unopened = state.chests.where((c) => !c.isOpened).toList();
          final opened = state.chests.where((c) => c.isOpened).toList();

          if (state.chests.isEmpty) {
            return const Center(child: Text('Belum ada peti. Selesaikan misi untuk mendapatkan peti!'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unopened.isNotEmpty) ...[
                const Text('Peti Tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...unopened.map((chest) => _buildChestItem(context, chest)),
                const SizedBox(height: 24),
              ],
              if (opened.isNotEmpty) ...[
                const Text('Peti Terbuka', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                const SizedBox(height: 12),
                ...opened.map((chest) => _buildChestItem(context, chest)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildChestItem(BuildContext context, chest) {
    final isOpened = chest.isOpened;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isOpened ? AppColors.muted : AppColors.warningLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              chest.rarityIcon.isNotEmpty ? chest.rarityIcon : (isOpened ? '🧳' : '🎁'),
              style: TextStyle(
                fontSize: 28,
                foreground: isOpened ? (Paint()..colorFilter = const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      0.5, 0,
                ])) : null,
              ),
            ),
          ),
        ),
        title: Text('Peti ${chest.rarity}', style: TextStyle(fontWeight: FontWeight.bold, color: isOpened ? AppColors.mutedForeground : AppColors.foreground)),
        subtitle: isOpened 
          ? Text('Hadiah: ${chest.rewardLabel}')
          : const Text('Tap untuk membuka!'),
        trailing: isOpened ? null : ElevatedButton(
          onPressed: () => context.read<GamificationBloc>().add(GamificationChestOpened(chest.id)),
          child: const Text('Buka'),
        ),
      ),
    );
  }

  void _showRewardDialog(BuildContext context, Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selamat!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Kamu mendapatkan:'),
            const SizedBox(height: 8),
            Text(reward['reward_label'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Luar Biasa!'),
            ),
          ),
        ],
      ),
    );
  }
}