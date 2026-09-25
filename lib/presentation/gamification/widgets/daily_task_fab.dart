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
  final GoRouter? router;

  const DailyTaskFab({super.key, this.bottomOffset = 96, this.router});

  @override
  State<DailyTaskFab> createState() => _DailyTaskFabState();
}

class _DailyTaskFabState extends State<DailyTaskFab> {
  late final GamificationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<GamificationBloc>()
      ..add(const GamificationDailyTasksRequested(processLogin: true));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  bool _isNavigating = false;

  void _openTasks() {
    if (_isNavigating) return;
    _isNavigating = true;

    final navigation =
        widget.router?.push('/gamification/daily-tasks') ??
        context.push('/gamification/daily-tasks');
    navigation.then((_) {
      _isNavigating = false;
      if (mounted) _bloc.add(const GamificationDailyTasksRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          final summary = state.dailyTasks;
          if (summary == null || summary.tasks.isEmpty) {
            return const SizedBox.shrink();
          }
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
    final label = claimable > 0
        ? 'Misi harian, $claimable siap diklaim'
        : 'Misi harian';

    return Semantics(
      button: true,
      label: label,
      onTap: _openTasks,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openTasks,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.fabGradientFrom,
                          AppColors.fabGradientTo,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Image.asset(
                        'assets/images/mascot/daily-missions.webp',
                        width: 42,
                        height: 50,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  if (claimable > 0)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 19,
                          minHeight: 19,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.notification,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '$claimable',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
