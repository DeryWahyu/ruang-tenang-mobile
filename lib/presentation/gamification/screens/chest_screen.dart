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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Peti Misteri', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listenWhen: (p, c) =>
            (c.openChestResult != null && p.openChestResult != c.openChestResult) ||
            (c.status == GamificationStatus.failure && p.status != c.status),
        listener: (context, state) {
          if (state.openChestResult != null && state.status == GamificationStatus.success) {
            _showRewardDialog(context, state.openChestResult);
          } else if (state.status == GamificationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.destructive),
            );
          }
        },
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.card_giftcard_rounded, size: 80, color: Colors.purple),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Peti Misteri Tersedia',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Peti misteri berisi hadiah acak mulai dari XP hingga Badge eksklusif.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.mutedForeground.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (state.chests.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedForeground),
                          SizedBox(height: 16),
                          Text('Tidak Ada Peti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 8),
                          Text(
                            'Kamu belum memiliki peti misteri. Selesaikan misi untuk mendapatkannya!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chest = state.chests[index];
                        return _buildChestCard(context, chest, state.status == GamificationStatus.submitting);
                      },
                      childCount: state.chests.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChestCard(BuildContext context, chest, bool isOpening) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purple.shade200),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOpening ? null : () {
            context.read<GamificationBloc>().add(GamificationChestOpened(chest.id.toString()));
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chest.rarityIcon.isNotEmpty ? chest.rarityIcon : '📦',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Peti ${_rarityLabel(chest.rarity)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOpening ? 'Membuka...' : 'Buka Peti',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRewardDialog(BuildContext context, reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.amber, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Selamat!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Kamu mendapatkan:\n${(reward['reward_label'] as String?)?.isNotEmpty == true ? reward['reward_label'] : _rewardText(reward)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.mutedForeground, height: 1.5),
              ),
              if ((reward['reward_value'] as num?) != null && (reward['reward_value'] as num) > 0) ...[
                const SizedBox(height: 16),
                Text(
                  '+${reward['reward_value']} ${_rewardUnit(reward['reward_type']?.toString())}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<GamificationBloc>().add(const GamificationChestsRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Klaim Hadiah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _rarityLabel(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'Legendaris';
      case 'epic':
        return 'Epik';
      case 'rare':
        return 'Langka';
      case 'common':
        return 'Biasa';
      default:
        return rarity.isEmpty ? 'Misteri' : '${rarity[0].toUpperCase()}${rarity.substring(1)}';
    }
  }

  String _rewardText(reward) {
    final type = reward['reward_type']?.toString() ?? '';
    final value = reward['reward_value'] ?? 0;
    switch (type) {
      case 'xp':
        return '$value XP';
      case 'coins':
        return '$value Koin Emas';
      case 'streak_freeze':
        return 'Streak Freeze';
      case 'xp_boost':
        return 'XP Boost';
      default:
        return 'Hadiah misteri';
    }
  }

  String _rewardUnit(String? type) {
    switch (type) {
      case 'xp':
        return 'XP';
      case 'coins':
        return 'Koin';
      default:
        return '';
    }
  }
}
