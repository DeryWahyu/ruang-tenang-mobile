import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_network_image.dart';
import '../../common/widgets/app_skeleton.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../common/widgets/app_alert_dialog.dart';

class RewardsScreen extends StatelessWidget {
  final bool showAppBar;
  const RewardsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GamificationBloc>()..add(const GamificationRewardsRequested()),
      child: _RewardsView(showAppBar: showAppBar),
    );
  }
}

class _RewardsView extends StatefulWidget {
  final bool showAppBar;
  const _RewardsView({required this.showAppBar});

  @override
  State<_RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<_RewardsView> {
  int _tabIndex = 0;
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Toko Hadiah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              backgroundColor: AppColors.card,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
            )
          : null,
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listenWhen: (p, c) =>
            p.successMessage != c.successMessage ||
            p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.successMessage.isNotEmpty) {
            if (state.successMessage == 'Tema berhasil diaktifkan') {
              context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
            }
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.successMessage),
                  backgroundColor: AppColors.success,
                ),
              );
          } else if (state.errorMessage.isNotEmpty &&
              state.status == GamificationStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.destructive,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.rewards.isEmpty &&
              state.status == GamificationStatus.loading) {
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
              children: List.generate(
                4,
                (_) => const AppSkeleton(
                  // Grid tiles already receive a tight height from their
                  // delegate. Keep the skeleton's own constraint finite so
                  // it can expand to the tile without requesting infinity.
                  height: 220,
                  borderRadius: 16,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<GamificationBloc>().add(
              const GamificationRewardsRequested(),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _balanceCard(state.coinBalance)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Hadiah')),
                        ButtonSegment(value: 1, label: Text('Riwayat')),
                        ButtonSegment(value: 2, label: Text('Tema')),
                      ],
                      selected: {_tabIndex},
                      onSelectionChanged: (selection) =>
                          setState(() => _tabIndex = selection.first),
                    ),
                  ),
                ),
                if (_tabIndex == 0)
                  SliverToBoxAdapter(child: _categoryFilters(state.rewards)),
                if (_tabIndex == 0 && _filteredRewards(state.rewards).isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Belum ada hadiah tersedia',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  )
                else if (_tabIndex == 0)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            // Leave enough room for the description and action
                            // button, including at the maximum tile width.
                            mainAxisExtent: 284,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _rewardCard(
                          context,
                          _filteredRewards(state.rewards)[index],
                          state,
                        ),
                        childCount: _filteredRewards(state.rewards).length,
                      ),
                    ),
                  ),
                if (_tabIndex == 1)
                  SliverToBoxAdapter(child: _claimsSection(context, state)),
                if (_tabIndex == 2)
                  SliverToBoxAdapter(child: _themesSection(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Reward> _filteredRewards(List<Reward> rewards) => _category == 'all'
      ? rewards
      : rewards.where((reward) => reward.rewardType == _category).toList();

  Widget _categoryFilters(List<Reward> rewards) {
    final categories = {'all', ...rewards.map((reward) => reward.rewardType)};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_typeLabel(category)),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'all' => 'Semua',
    'theme' => 'Tema',
    'xp_boost' => 'XP Boost',
    'general' => 'Umum',
    _ => type.replaceAll('_', ' '),
  };

  String _themeLabel(String theme) =>
      theme == 'default' ? 'Bawaan' : theme.replaceAll('_', ' ');

  Widget _claimsSection(BuildContext context, GamificationState state) {
    if (state.rewardClaims.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('Belum ada hadiah yang ditukar')),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          for (final claim in state.rewardClaims)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  (claim['reward'] as Map?)?['name']?.toString() ?? 'Hadiah',
                ),
                subtitle: Text(_claimDate(claim['claimed_at']?.toString())),
                trailing: Text(
                  '${claim['coin_spent'] ?? 0} koin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (state.rewardClaimsPage < state.rewardClaimsTotalPages)
            OutlinedButton(
              onPressed: state.status == GamificationStatus.loading
                  ? null
                  : () => context.read<GamificationBloc>().add(
                      const GamificationRewardClaimsMoreRequested(),
                    ),
              child: const Text('Muat lebih banyak'),
            ),
        ],
      ),
    );
  }

  String _claimDate(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _themesSection(BuildContext context, GamificationState state) {
    const palette = <String, Color>{
      'default': Color(0xFFEF4444),
      'ocean_calm': Color(0xFF0EA5E9),
      'forest_zen': Color(0xFF16A34A),
      'sunset_warmth': Color(0xFFEA580C),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tema yang dimiliki',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih tema untuk memperbarui tampilan akun Anda.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          for (final theme in state.ownedThemes)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: palette[theme] ?? AppColors.primary,
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Colors.white,
                  ),
                ),
                title: Text(_themeLabel(theme)),
                subtitle: Text(
                  theme == state.activeTheme ? 'Sedang aktif' : 'Dimiliki',
                ),
                trailing: theme == state.activeTheme
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      )
                    : TextButton(
                        onPressed: state.status == GamificationStatus.submitting
                            ? null
                            : () => context.read<GamificationBloc>().add(
                                GamificationThemeActivated(theme),
                              ),
                        child: const Text('Aktifkan'),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _balanceCard(int balance) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.fabGradientFrom, AppColors.fabGradientTo],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Koin Emas',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '$balance',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(
    BuildContext context,
    Reward reward,
    GamificationState state,
  ) {
    final canAfford = state.coinBalance >= reward.coinCost;
    final available = reward.isAvailable;
    final submitting = state.status == GamificationStatus.submitting;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: reward.image.isNotEmpty
                  ? AppNetworkImage(
                      url: reward.image,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.card_giftcard_rounded,
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.accentOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.coinCost}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      !available
                          ? 'Habis'
                          : (!canAfford ? 'Koin Kurang' : 'Tukar'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
      child: const Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          color: AppColors.accentOrange,
          size: 40,
        ),
      ),
    );
  }

  void _confirm(BuildContext context, Reward reward) {
    final bloc = context.read<GamificationBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AppAlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tukar Hadiah'),
        content: Text(
          'Tukar "${reward.name}" dengan ${reward.coinCost} koin emas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
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
