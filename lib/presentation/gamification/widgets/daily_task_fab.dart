import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

/// Floating daily-task button shown across the main dashboard, mirroring the
/// web `DailyTaskFAB`. It loads today's tasks to display a claimable-count
/// badge, and opens the full Daily Tasks page when tapped.
class DailyTaskFab extends StatefulWidget {
  /// Extra bottom offset so the FAB sits above the floating bottom nav bar
  /// (and above a screen's own FAB / mini-player when present).
  final double bottomOffset;

  const DailyTaskFab({super.key, this.bottomOffset = 96});

  @override
  State<DailyTaskFab> createState() => _DailyTaskFabState();
}

class _DailyTaskFabState extends State<DailyTaskFab> {
  late final GamificationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<GamificationBloc>()..add(const GamificationDailyTasksRequested(processLogin: true));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _openTasks() {
    // Defer to after the current frame so the route push doesn't mutate the
    // widget tree synchronously inside the pointer/hover event — this avoids
    // MouseTracker reentrancy assertions on desktop/web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.push('/gamification/daily-tasks').then((_) {
        if (mounted) _bloc.add(const GamificationDailyTasksRequested());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          final summary = state.dailyTasks;
          if (summary == null || summary.tasks.isEmpty) return const SizedBox.shrink();
          final claimable = summary.claimableCount;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: 16,
                bottom: widget.bottomOffset,
                child: _fabButton(claimable),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fabButton(int claimable) {
    return GestureDetector(
      onTap: _openTasks,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.fabGradientFrom, AppColors.fabGradientTo],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 24),
            ),
            if (claimable > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: AppColors.notification,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text('$claimable',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
