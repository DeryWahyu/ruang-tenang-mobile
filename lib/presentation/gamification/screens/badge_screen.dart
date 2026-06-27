import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationBadgesRequested()),
      child: const _BadgeView(),
    );
  }
}

class _BadgeView extends StatelessWidget {
  const _BadgeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Badge'),
        centerTitle: true,
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == GamificationStatus.failure) {
            return Center(child: Text(state.errorMessage));
          }

          if (state.badges.isEmpty) {
            return const Center(child: Text('Belum ada badge'));
          }

          // Group by category
          final Map<String, List<dynamic>> grouped = {};
          for (var badge in state.badges) {
            if (!grouped.containsKey(badge.category)) {
              grouped[badge.category] = [];
            }
            grouped[badge.category]!.add(badge);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final category = grouped.keys.elementAt(index);
              final badges = grouped[category]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.mutedForeground)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, i) {
                      final badge = badges[i];
                      return _buildBadgeItem(context, badge);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, badge) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: badge.earned ? AppColors.warningLight : AppColors.muted,
            border: Border.all(
              color: badge.earned ? AppColors.warning : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              badge.icon.isNotEmpty ? badge.icon : '🛡️',
              style: TextStyle(
                fontSize: 32,
                foreground: Paint()..colorFilter = badge.earned ? null : const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      0.5, 0,
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.badgeName,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 12,
            fontWeight: badge.earned ? FontWeight.bold : FontWeight.normal,
            color: badge.earned ? AppColors.foreground : AppColors.mutedForeground,
          ),
        ),
        if (!badge.earned) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: badge.progressPercent / 100,
            backgroundColor: AppColors.muted,
            minHeight: 4,
          ),
        ],
      ],
    );
  }
}