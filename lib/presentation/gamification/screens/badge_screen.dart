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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Koleksi Badge', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.status == GamificationStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, style: const TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            );
          }

          if (state.badges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.workspace_premium_rounded, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('Belum Ada Badge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Selesaikan misi untuk mendapatkan badge pertamamu!', style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            );
          }

          // Group by category
          final Map<String, List<dynamic>> grouped = {};
          for (var badge in state.badges) {
            if (!grouped.containsKey(badge.category)) {
              grouped[badge.category] = [];
            }
            grouped[badge.category]!.add(badge);
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pencapaianmu',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kumpulkan lencana dengan menyelesaikan berbagai aktivitas kesehatan mental.',
                        style: TextStyle(fontSize: 14, color: AppColors.mutedForeground.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = grouped.keys.elementAt(index);
                      final badges = grouped[category]!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.category_rounded, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  category.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.foreground, letterSpacing: 1.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: badges.length,
                              itemBuilder: (context, i) {
                                final badge = badges[i];
                                return _buildBadgeItem(context, badge);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, badge) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: badge.earned ? Colors.amber.shade100 : AppColors.muted.withOpacity(0.5),
            border: Border.all(
              color: badge.earned ? Colors.amber.shade400 : AppColors.border,
              width: badge.earned ? 3 : 1,
            ),
            boxShadow: badge.earned ? [
              BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
            ] : null,
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
                  0,      0,      0,      0.3, 0, // Lower opacity for unearned
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          badge.badgeName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: badge.earned ? FontWeight.bold : FontWeight.w500,
            color: badge.earned ? AppColors.foreground : AppColors.mutedForeground,
          ),
        ),
        if (!badge.earned && badge.progressPercent != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: badge.progressPercent / 100,
              backgroundColor: AppColors.muted,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
        ],
      ],
    );
  }
}
