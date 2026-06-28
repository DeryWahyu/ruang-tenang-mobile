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
  /// Extra bottom offset so the FAB sits above the floating bottom nav bar.
  final double bottomOffset;

  /// When false the FAB is hidden (e.g. on screens with their own FAB).
  final bool visible;

  const DailyTaskFab({super.key, this.bottomOffset = 96, this.visible = true});

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
          if (!widget.visible) return const SizedBox.shrink();
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
        width: 64,
        height: 64,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.fabGradientFrom, AppColors.fabGradientTo]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.accentOrange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
            ),
            if (claimable > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  decoration: BoxDecoration(
                    color: AppColors.notification,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text('$claimable',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
