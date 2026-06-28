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

class _SessionViewState extends State<_SessionView> with SingleTickerProviderStateMixin {
  late final AnimationController _breath; // 0 = contracted, 1 = expanded

  _Phase _phase = _Phase.inhale;
  int _phaseSecondsLeft = 0;
  int _phaseDuration = 0;
  int _cycles = 0;
  int _elapsed = 0;
  Timer? _ticker;
  bool _running = false;
  bool _started = false;

  static const int _targetSeconds = 180;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.technique.inhaleDuration.clamp(1, 60)),
      value: 0,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  int _durationFor(_Phase p) {
    switch (p) {
      case _Phase.inhale:
        return widget.technique.inhaleDuration;
      case _Phase.inhaleHold:
        return widget.technique.inhaleHoldDuration;
      case _Phase.exhale:
        return widget.technique.exhaleDuration;
      case _Phase.exhaleHold:
        return widget.technique.exhaleHoldDuration;
    }
  }

  _Phase _next(_Phase p) {
    switch (p) {
      case _Phase.inhale:
        return _Phase.inhaleHold;
      case _Phase.inhaleHold:
        return _Phase.exhale;
      case _Phase.exhale:
        return _Phase.exhaleHold;
      case _Phase.exhaleHold:
        return _Phase.inhale;
    }
  }

  void _start() {
    setState(() {
      _started = true;
      _running = true;
    });
    context.read<BreathingBloc>().add(
          BreathingSessionStarted(technique: widget.technique, targetDurationSeconds: _targetSeconds),
        );
    _enterPhase(_Phase.inhale);
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer _) {
    if (!_running || !mounted) return;
    setState(() {
      _elapsed++;
      _phaseSecondsLeft--;
    });
    if (_elapsed >= _targetSeconds) {
      _complete(true);
      return;
    }
    if (_phaseSecondsLeft <= 0) {
      _advancePhase();
    }
  }

  void _advancePhase() {
    var next = _next(_phase);
    // Skip phases with zero duration (e.g. a technique without holds).
    var guard = 0;
    while (_durationFor(next) <= 0 && guard < 4) {
      next = _next(next);
      guard++;
    }
    // A full cycle completes when we wrap back to the inhale phase.
    if (next == _Phase.inhale) {
      _cycles++;
    }
    _enterPhase(next);
  }

  void _enterPhase(_Phase p) {
    final dur = _durationFor(p);
    if (dur <= 0) {
      // shouldn't happen (skipped), but guard
      _advancePhase();
      return;
    }
    setState(() {
      _phase = p;
      _phaseDuration = dur;
      _phaseSecondsLeft = dur;
    });
    HapticFeedback.lightImpact();
    _animateForPhase(p, dur);
  }

  void _animateForPhase(_Phase p, int seconds) {
    final d = Duration(milliseconds: (seconds * 1000));
    switch (p) {
      case _Phase.inhale:
        _breath.animateTo(1.0, duration: d, curve: Curves.easeInOut);
        break;
      case _Phase.exhale:
        _breath.animateTo(0.0, duration: d, curve: Curves.easeInOut);
        break;
      case _Phase.inhaleHold:
      case _Phase.exhaleHold:
        // Stay at current size during holds.
        break;
    }
  }

  void _togglePause() {
    setState(() => _running = !_running);
    if (_running) {
      // Resume animation for the remaining time of the current phase.
      _animateForPhase(_phase, _phaseSecondsLeft.clamp(1, _phaseDuration));
    } else {
      _breath.stop();
    }
  }

  void _complete(bool completed) {
    _ticker?.cancel();
    _breath.stop();
    if (mounted) setState(() => _running = false);

    final bloc = context.read<BreathingBloc>();
    final active = bloc.state.activeSession;
    if (active != null) {
      bloc.add(BreathingSessionCompleted(
        sessionId: active.id,
        durationSeconds: _elapsed,
        cyclesCompleted: _cycles,
        completed: completed,
        completedPercentage: (_elapsed / _targetSeconds * 100).clamp(0, 100).toInt(),
      ));
    }
    // Defer the dialog so we don't mutate the tree inside a pointer event.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showCompletionDialog(completed);
    });
  }

  void _showCompletionDialog(bool completed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: _phaseColor(_Phase.inhale).withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(completed ? Icons.celebration_rounded : Icons.spa_rounded,
                  color: _phaseColor(_Phase.inhale), size: 44),
            ),
            const SizedBox(height: 16),
            Text(completed ? 'Sesi Selesai! 🎉' : 'Kerja Bagus',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Durasi ${_elapsed ~/ 60}m ${_elapsed % 60}d • $_cycles siklus',
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String get _phaseLabel {
    switch (_phase) {
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

  Color _phaseColor(_Phase p) {
    switch (p) {
      case _Phase.inhale:
        return const Color(0xFF38BDF8); // sky
      case _Phase.inhaleHold:
        return const Color(0xFFA78BFA); // violet
      case _Phase.exhale:
        return const Color(0xFF34D399); // emerald
      case _Phase.exhaleHold:
        return const Color(0xFFA78BFA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor(_phase);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.technique.name),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (_started) {
              _complete(false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_started) _topStats(color),
              Expanded(child: Center(child: _breathingCircle(color))),
              if (!_started) _preStart(color) else _controls(color),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topStats(Color color) {
    final progress = (_elapsed / _targetSeconds).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statPill(Icons.timer_outlined,
                '${(_elapsed ~/ 60).toString().padLeft(2, '0')}:${(_elapsed % 60).toString().padLeft(2, '0')}'),
            _statPill(Icons.refresh_rounded, '$_cycles siklus'),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _statPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border.withOpacity(0.5))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppColors.mutedForeground),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _breathingCircle(Color color) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) {
        final t = _breath.value; // 0..1
        const maxD = 260.0;
        const minD = 150.0;
        final d = minD + (maxD - minD) * t;
        return SizedBox(
          width: maxD + 36,
          height: maxD + 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft outer halo
              Container(
                width: maxD + 36,
                height: maxD + 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.06)),
              ),
              // Breathing orb
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.85), color.withOpacity(0.35)],
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.35 + 0.25 * t), blurRadius: 30 + 20 * t, spreadRadius: 2),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _started ? _phaseLabel : 'Siap?',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_started) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${_phaseSecondsLeft < 0 ? 0 : _phaseSecondsLeft}',
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _preStart(Color color) {
    return Column(
      children: [
        Text(
          widget.technique.description,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.mutedForeground, height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _patternChip('Tarik ${widget.technique.inhaleDuration}s'),
            if (widget.technique.inhaleHoldDuration > 0) _patternChip('Tahan ${widget.technique.inhaleHoldDuration}s'),
            _patternChip('Buang ${widget.technique.exhaleDuration}s'),
            if (widget.technique.exhaleHoldDuration > 0) _patternChip('Tahan ${widget.technique.exhaleHoldDuration}s'),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Mulai Sesi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _patternChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
    );
  }

  Widget _controls(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _complete(false),
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Selesai'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
              side: BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_running ? 'Jeda' : 'Lanjut'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
