import 'dart:async';
import 'dart:math' as math;
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

enum _Stage { setup, active, finished }

/// Duration options (seconds) mirroring the web experience.
const List<({int seconds, String label})> _durationOptions = [
  (seconds: 120, label: '2 menit'),
  (seconds: 300, label: '5 menit'),
  (seconds: 600, label: '10 menit'),
  (seconds: 900, label: '15 menit'),
];

/// Mood options shared with web (subset relevant for breathing).
const List<({String id, String label, IconData icon})> _moodOptions = [
  (id: 'anxious', label: 'Cemas', icon: Icons.cloud_outlined),
  (id: 'stressed', label: 'Stres', icon: Icons.bolt_outlined),
  (id: 'tired', label: 'Lelah', icon: Icons.battery_2_bar_outlined),
  (id: 'neutral', label: 'Biasa', icon: Icons.sentiment_neutral_outlined),
  (id: 'calm', label: 'Tenang', icon: Icons.air_rounded),
  (id: 'happy', label: 'Senang', icon: Icons.sentiment_satisfied_outlined),
];

class _SessionViewState extends State<_SessionView> with SingleTickerProviderStateMixin {
  late final AnimationController _breath; // 0 = contracted, 1 = expanded

  _Stage _stage = _Stage.setup;
  _Phase _phase = _Phase.inhale;
  int _phaseSecondsLeft = 0;
  int _phaseDuration = 0;
  int _cycles = 0;
  int _elapsed = 0;
  Timer? _ticker;
  bool _running = false;

  // Setup selections
  int _targetSeconds = 300;
  String? _moodBefore;
  String? _moodAfter;

  bool get _hasAnyPhase =>
      widget.technique.inhaleDuration > 0 ||
      widget.technique.inhaleHoldDuration > 0 ||
      widget.technique.exhaleDuration > 0 ||
      widget.technique.exhaleHoldDuration > 0;

  int get _cycleDuration =>
      widget.technique.inhaleDuration +
      widget.technique.inhaleHoldDuration +
      widget.technique.exhaleDuration +
      widget.technique.exhaleHoldDuration;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.technique.inhaleDuration.clamp(1, 60)),
      value: 0,
    );
    // Default duration: nearest sensible option.
    _targetSeconds = 300;
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

  _Phase _nextRaw(_Phase p) {
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
    if (!_hasAnyPhase) {
      // Degenerate technique: nothing to pace. Inform and exit.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teknik ini belum memiliki pola pernapasan yang valid.')),
      );
      return;
    }
    setState(() {
      _stage = _Stage.active;
      _running = true;
    });
    context.read<BreathingBloc>().add(
          BreathingSessionStarted(
            technique: widget.technique,
            targetDurationSeconds: _targetSeconds,
            moodBefore: _moodBefore ?? '',
            hapticFeedbackEnabled: true,
          ),
        );
    _enterPhase(_firstPhase());
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  _Phase _firstPhase() {
    for (final p in [_Phase.inhale, _Phase.inhaleHold, _Phase.exhale, _Phase.exhaleHold]) {
      if (_durationFor(p) > 0) return p;
    }
    return _Phase.inhale;
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
    var next = _nextRaw(_phase);
    // Skip zero-duration phases. Bounded by 4 since there are 4 phases; if
    // none has a positive duration we finish instead of recursing forever.
    var guard = 0;
    while (_durationFor(next) <= 0 && guard < 4) {
      next = _nextRaw(next);
      guard++;
    }
    if (_durationFor(next) <= 0) {
      // No positive-duration phase exists — end the session safely.
      _complete(true);
      return;
    }
    if (next == _Phase.inhale) {
      _cycles++;
    }
    _enterPhase(next);
  }

  void _enterPhase(_Phase p) {
    final dur = _durationFor(p);
    if (dur <= 0) {
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
        break;
    }
  }

  void _togglePause() {
    setState(() => _running = !_running);
    if (_running) {
      _animateForPhase(_phase, _phaseSecondsLeft.clamp(1, _phaseDuration));
    } else {
      _breath.stop();
    }
  }

  void _complete(bool completed) {
    _ticker?.cancel();
    _breath.stop();
    if (mounted) {
      setState(() {
        _running = false;
        _stage = _Stage.finished;
      });
    }
  }

  void _submitCompletion(bool completed) {
    final bloc = context.read<BreathingBloc>();
    final active = bloc.state.activeSession;
    final pct = (_elapsed / _targetSeconds * 100).clamp(0, 100).toInt();
    if (active != null) {
      bloc.add(BreathingSessionCompleted(
        sessionId: active.id,
        durationSeconds: _elapsed,
        cyclesCompleted: _cycles,
        completed: completed,
        completedPercentage: pct,
        moodAfter: _moodAfter ?? '',
      ));
    }
    context.pop();
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
        return 'Jeda';
    }
  }

  String get _phaseCue {
    switch (_phase) {
      case _Phase.inhale:
        return 'Biarkan dada & perut mengembang perlahan';
      case _Phase.inhaleHold:
        return 'Diam sebentar di puncak napas';
      case _Phase.exhale:
        return 'Lepaskan tegang, hembuskan lebih pelan';
      case _Phase.exhaleHold:
        return 'Nikmati ruang hening sejenak';
    }
  }

  Color _phaseColor(_Phase p) {
    switch (p) {
      case _Phase.inhale:
        return const Color(0xFF38BDF8);
      case _Phase.inhaleHold:
        return const Color(0xFFA78BFA);
      case _Phase.exhale:
        return const Color(0xFF34D399);
      case _Phase.exhaleHold:
        return const Color(0xFFA78BFA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _stage == _Stage.active ? _phaseColor(_phase) : const Color(0xFF38BDF8);
    return BlocListener<BreathingBloc, BreathingState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        // If starting the session failed, stop the timer and inform the user.
        if (state.status == BreathingStatus.failure && _stage == _Stage.active) {
          _ticker?.cancel();
          _breath.stop();
          if (mounted) {
            setState(() {
              _running = false;
              _stage = _Stage.setup;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage.isEmpty ? 'Gagal memulai sesi' : state.errorMessage)),
            );
          }
        }
      },
      child: Scaffold(
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
              if (_stage == _Stage.active) {
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
            child: switch (_stage) {
              _Stage.setup => _setupView(color),
              _Stage.active => _activeView(color),
              _Stage.finished => _finishedView(color),
            },
          ),
        ),
      ),
    );
  }

  // ---------------- Setup ----------------
  Widget _setupView(Color color) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.technique.description,
            style: const TextStyle(color: AppColors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _patternChip('Tarik ${widget.technique.inhaleDuration}s'),
              if (widget.technique.inhaleHoldDuration > 0) _patternChip('Tahan ${widget.technique.inhaleHoldDuration}s'),
              _patternChip('Buang ${widget.technique.exhaleDuration}s'),
              if (widget.technique.exhaleHoldDuration > 0) _patternChip('Tahan ${widget.technique.exhaleHoldDuration}s'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Durasi Sesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durationOptions.map((opt) {
              final selected = _targetSeconds == opt.seconds;
              return ChoiceChip(
                label: Text(opt.label),
                selected: selected,
                onSelected: (_) => setState(() => _targetSeconds = opt.seconds),
                selectedColor: color.withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  color: selected ? color : AppColors.foreground,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: selected ? color : AppColors.border),
                ),
                backgroundColor: AppColors.card,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Bagaimana perasaanmu sekarang?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Opsional — membantu kami menyesuaikan rekomendasi.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moodOptions.map((m) {
              final selected = _moodBefore == m.id;
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(m.icon, size: 16, color: selected ? color : AppColors.mutedForeground),
                label: Text(m.label),
                selected: selected,
                onSelected: (_) => setState(() => _moodBefore = selected ? null : m.id),
                selectedColor: color.withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  color: selected ? color : AppColors.foreground,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: selected ? color : AppColors.border),
                ),
                backgroundColor: AppColors.card,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
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
      ),
    );
  }

  // ---------------- Active ----------------
  Widget _activeView(Color color) {
    return Column(
      children: [
        _topStats(color),
        Expanded(child: Center(child: _breathingCircle(color))),
        const SizedBox(height: 8),
        Text(
          _phaseCue,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mutedForeground, height: 1.4),
        ),
        const SizedBox(height: 16),
        _controls(color),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _topStats(Color color) {
    final progress = (_elapsed / _targetSeconds).clamp(0.0, 1.0);
    final totalCycles = _cycleDuration > 0 ? (_targetSeconds / _cycleDuration).floor() : 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statPill(Icons.timer_outlined,
                '${(_elapsed ~/ 60).toString().padLeft(2, '0')}:${(_elapsed % 60).toString().padLeft(2, '0')}'),
            _statPill(Icons.refresh_rounded, totalCycles > 0 ? '$_cycles/$totalCycles siklus' : '$_cycles siklus'),
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
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
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
        final phaseProgress = _phaseDuration > 0
            ? (1 - (_phaseSecondsLeft.clamp(0, _phaseDuration) / _phaseDuration))
            : 0.0;
        return SizedBox(
          width: maxD + 48,
          height: maxD + 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft outer halo
              Container(
                width: maxD + 48,
                height: maxD + 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.06)),
              ),
              // Phase-progress ring (a calm sweep, not a ticking number)
              SizedBox(
                width: maxD + 24,
                height: maxD + 24,
                child: CustomPaint(
                  painter: _PhaseRingPainter(progress: phaseProgress, color: color),
                ),
              ),
              // Breathing orb
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.35)],
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.35 + 0.25 * t), blurRadius: 30 + 20 * t, spreadRadius: 2),
                  ],
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'IKUTI RITME',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phaseLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1),
                        ),
                        const SizedBox(height: 8),
                        _pacingDots(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pacingDots() {
    final total = _phaseDuration.clamp(0, 8);
    if (total <= 0) return const SizedBox.shrink();
    final elapsedInPhase = _phaseDuration - _phaseSecondsLeft;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final filled = i < elapsedInPhase;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: filled ? 0.95 : 0.4),
          ),
        );
      }),
    );
  }

  Widget _controls(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _complete(_elapsed / _targetSeconds >= 0.95),
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

  // ---------------- Finished (reflection) ----------------
  Widget _finishedView(Color color) {
    final completed = _elapsed / _targetSeconds >= 0.95;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(completed ? Icons.celebration_rounded : Icons.spa_rounded, color: color, size: 44),
          ),
          const SizedBox(height: 16),
          Text(completed ? 'Sesi Selesai!' : 'Kerja Bagus',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Durasi ${_elapsed ~/ 60}m ${_elapsed % 60}d • $_cycles siklus',
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 28),
          const Text('Bagaimana perasaanmu sekarang?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _moodOptions.map((m) {
              final selected = _moodAfter == m.id;
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(m.icon, size: 16, color: selected ? color : AppColors.mutedForeground),
                label: Text(m.label),
                selected: selected,
                onSelected: (_) => setState(() => _moodAfter = selected ? null : m.id),
                selectedColor: color.withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  color: selected ? color : AppColors.foreground,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: selected ? color : AppColors.border),
                ),
                backgroundColor: AppColors.card,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitCompletion(completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Simpan & Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _patternChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
    );
  }
}

/// Paints a soft progress arc representing the current phase progress.
class _PhaseRingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _PhaseRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = color.withValues(alpha: 0.15);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.85);

    canvas.drawCircle(center, radius, bg);
    final sweep = (2 * math.pi) * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_PhaseRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
