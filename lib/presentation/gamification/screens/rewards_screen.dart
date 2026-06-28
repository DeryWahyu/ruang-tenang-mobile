import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationRewardsRequested()),
      child: const _RewardsView(),
    );
  }
}

class _RewardsView extends StatelessWidget {
  const _RewardsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Toko Hadiah', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (state.rewards.isEmpty && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<GamificationBloc>().add(const GamificationRewardsRequested()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _balanceCard(state.coinBalance)),
                if (state.rewards.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('Belum ada hadiah tersedia',
                            style: TextStyle(color: AppColors.mutedForeground)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _rewardCard(context, state.rewards[index], state),
                        childCount: state.rewards.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _balanceCard(int balance) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.fabGradientFrom, AppColors.fabGradientTo]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo Koin Emas', style: TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 2),
              Text('$balance',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(BuildContext context, Reward reward, GamificationState state) {
    final canAfford = state.coinBalance >= reward.coinCost;
    final available = reward.isAvailable;
    final submitting = state.status == GamificationStatus.submitting;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Builder(builder: (_) {
                final url = resolveMediaUrl(reward.image);
                return url != null
                    ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder();
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(reward.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.accentOrange, size: 16),
                    const SizedBox(width: 4),
                    Text('${reward.coinCost}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!available || !canAfford || submitting)
                        ? null
                        : () => _confirm(context, reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.muted,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      !available ? 'Habis' : (!canAfford ? 'Koin Kurang' : 'Tukar'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.accentOrangeLight,
      child: const Center(child: Icon(Icons.card_giftcard_rounded, color: AppColors.accentOrange, size: 40)),
    );
  }

  void _confirm(BuildContext context, Reward reward) {
    final bloc = context.read<GamificationBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tukar Hadiah'),
        content: Text('Tukar "${reward.name}" dengan ${reward.coinCost} koin emas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(GamificationRewardClaimed(reward.id));
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }
}
