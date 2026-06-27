import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/breathing.dart';
import '../bloc/breathing_bloc.dart';
import '../bloc/breathing_event.dart';
import '../bloc/breathing_state.dart';

class BreathingSessionScreen extends StatelessWidget {
  final BreathingTechnique? technique;
  const BreathingSessionScreen({super.key, this.technique});

  @override
  Widget build(BuildContext context) {
    final tech = technique ?? (GoRouterState.of(context).extra as BreathingTechnique?);
    if (tech == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sesi Pernapasan')),
        body: const Center(child: Text('Teknik tidak ditemukan')),
      );
    }
    return BlocProvider(
      create: (_) => sl<BreathingBloc>(),
      child: _SessionView(technique: tech),
    );
  }
}

class _SessionView extends StatefulWidget {
  final BreathingTechnique technique;
  const _SessionView({required this.technique});

  @override
  State<_SessionView> createState() => _SessionViewState();
}

enum _Phase { inhale, inhaleHold, exhale, exhaleHold }

class _SessionViewState extends State<_SessionView> with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _progressController;

  _Phase _currentPhase = _Phase.inhale;
  int _cyclesCompleted = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  Timer? _phaseTimer;
  bool _isRunning = false;
  bool _hasStarted = false;

  int get _targetSeconds => 180;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: Duration(seconds: widget.technique.inhaleDuration));
    _progressController = AnimationController(vsync: this, duration: Duration(seconds: _targetSeconds));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _breathController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _hasStarted = true;
      _isRunning = true;
    });
    context.read<BreathingBloc>().add(BreathingSessionStarted(technique: widget.technique, targetDurationSeconds: _targetSeconds));
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _targetSeconds) _completeSession(true);
    });
    _startPhase(_Phase.inhale);
  }

  void _startPhase(_Phase phase) {
    setState(() => _currentPhase = phase);
    int duration;
    switch (phase) {
      case _Phase.inhale:
        duration = widget.technique.inhaleDuration;
        _breathController.duration = Duration(seconds: duration);
        _breathController.forward(from: 0);
        HapticFeedback.lightImpact();
        break;
      case _Phase.inhaleHold:
        duration = widget.technique.inhaleHoldDuration;
        break;
      case _Phase.exhale:
        duration = widget.technique.exhaleDuration;
        _breathController.duration = Duration(seconds: duration);
        _breathController.reverse(from: 1);
        HapticFeedback.lightImpact();
        break;
      case _Phase.exhaleHold:
        duration = widget.technique.exhaleHoldDuration;
        break;
    }
    if (duration <= 0) {
      _nextPhase();
      return;
    }
    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: duration), _nextPhase);
  }

  void _nextPhase() {
    switch (_currentPhase) {
      case _Phase.inhale:
        _startPhase(_Phase.inhaleHold);
        break;
      case _Phase.inhaleHold:
        _startPhase(_Phase.exhale);
        break;
      case _Phase.exhale:
        _startPhase(_Phase.exhaleHold);
        break;
      case _Phase.exhaleHold:
        setState(() => _cyclesCompleted++);
        _startPhase(_Phase.inhale);
        break;
    }
  }

  void _togglePause() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _breathController.forward();
    } else {
      _breathController.stop();
      _phaseTimer?.cancel();
    }
  }

  void _completeSession(bool completed) {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _breathController.stop();
    _progressController.stop();
    setState(() => _isRunning = false);

    final bloc = context.read<BreathingBloc>();
    final activeSession = bloc.state.activeSession;
    if (activeSession != null) {
      bloc.add(BreathingSessionCompleted(
        sessionId: activeSession.id,
        durationSeconds: _elapsedSeconds,
        cyclesCompleted: _cyclesCompleted,
        completed: completed,
        completedPercentage: (_elapsedSeconds / _targetSeconds * 100).clamp(0, 100).toInt(),
      ));
    }
    _showCompletionDialog(completed);
  }

  void _showCompletionDialog(bool completed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(completed ? Icons.celebration : Icons.check_circle_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(completed ? 'Selesai!' : 'Sesi Berakhir'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Durasi: ${_elapsedSeconds ~/ 60} menit ${_elapsedSeconds % 60} detik'),
            const SizedBox(height: 8),
            Text('Siklus selesai: $_cyclesCompleted'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  String get _phaseLabel {
    switch (_currentPhase) {
      case _Phase.inhale:
        return 'Tarik Napas';
      case _Phase.inhaleHold:
        return 'Tahan';
      case _Phase.exhale:
        return 'Buang Napas';
      case _Phase.exhaleHold:
        return 'Tahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BreathingBloc, BreathingState>(
      listener: (context, state) {
        if (state.activeSession != null) {
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.technique.name),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_hasStarted && _isRunning) {
                _completeSession(false);
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasStarted) ...[
                Text(
                  '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.mutedForeground),
                ),
                const SizedBox(height: 8),
                Text('Siklus: $_cyclesCompleted', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
                const SizedBox(height: 32),
              ],
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final size = 120.0 + (_breathController.value * 80.0);
                  return Container(
                    width: size + 40,
                    height: size + 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                    child: Center(
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.6),
                              AppColors.primary.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _hasStarted ? _phaseLabel : 'Mulai',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              if (!_hasStarted)
                Column(
                  children: [
                    Text(widget.technique.description, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _startSession,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Mulai Sesi'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _completeSession(false),
                      icon: const Icon(Icons.stop),
                      label: const Text('Selesai'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _togglePause,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isRunning ? 'Pause' : 'Lanjut'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}