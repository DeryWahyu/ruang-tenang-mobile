import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class XpBoostScreen extends StatelessWidget {
  const XpBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<XpBoostCubit>()..load(),
      child: const _XpBoostView(),
    );
  }
}

class _XpBoostView extends StatelessWidget {
  const _XpBoostView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('XP Boost & Combo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      body: BlocBuilder<XpBoostCubit, ViewState<XpBoostData>>(
        builder: (context, state) {
          if (state.data == null && state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_outlined, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.error.isEmpty ? 'Gagal memuat' : state.error,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => context.read<XpBoostCubit>().load(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final data = state.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<XpBoostCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _multiplierCard(data.effectiveMultiplier),
                const SizedBox(height: 20),
                _boostCard(data.boost),
                const SizedBox(height: 20),
                _comboCard(data.combo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _multiplierCard(double multiplier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.fabGradientFrom, AppColors.fabGradientTo]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.flash_on_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text('${multiplier.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const Text('Multiplier XP Efektif', style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _boostCard(XPBoost? boost) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              const Text('XP Boost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (boost == null)
            const Text('Tidak ada boost aktif saat ini.',
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 13))
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${boost.multiplier.toStringAsFixed(1)}x boost',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange, fontSize: 18)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                  child: Text('Sisa ${_fmt(boost.remainingSeconds)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Sumber: ${boost.triggerType}',
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _comboCard(ComboStatus combo) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Combo Chain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _comboStat('${combo.comboCount}', 'Combo'),
              _comboStat('${combo.multiplier.toStringAsFixed(1)}x', 'Multiplier'),
              _comboStat('${combo.nextMultiplier.toStringAsFixed(1)}x', 'Berikutnya'),
            ],
          ),
          if (combo.comboCount > 0 && combo.expiresInSeconds > 0) ...[
            const SizedBox(height: 12),
            Center(
              child: Text('Combo berakhir dalam ${_fmt(combo.expiresInSeconds)}',
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _comboStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
      ],
    );
  }

  String _fmt(int seconds) {
    if (seconds <= 0) return '0d';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}j ${m}m';
    if (m > 0) return '${m}m ${s}d';
    return '${s}d';
  }
}
