import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class DailySpinScreen extends StatelessWidget {
  const DailySpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationSpinWheelRequested()),
      child: const _DailySpinView(),
    );
  }
}

class _DailySpinView extends StatefulWidget {
  const _DailySpinView();

  @override
  State<_DailySpinView> createState() => _DailySpinViewState();
}

class _DailySpinViewState extends State<_DailySpinView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double> _animation = const AlwaysStoppedAnimation(0);
  bool _isSpinning = false;
  bool _handledResult = false;

  // Palette for the wheel sectors.
  static const _sectorColors = [
    Color(0xFFFB923C), // orange
    Color(0xFFFBBF24), // amber
    Color(0xFFF472B6), // pink
    Color(0xFF60A5FA), // blue
    Color(0xFF34D399), // emerald
    Color(0xFFA78BFA), // violet
    Color(0xFFF87171), // red
    Color(0xFF22D3EE), // cyan
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        final result = context.read<GamificationBloc>().state.spinResult;
        if (result != null) _showRewardDialog(result);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _handledResult = false;
    });
    context.read<GamificationBloc>().add(const GamificationSpinRequested());
  }

  void _animateToResult(int slotIndex, int slotCount) {
    if (slotCount <= 0) {
      setState(() => _isSpinning = false);
      return;
    }
    // 5 full turns + bring the winning slot to the top pointer.
    final endTurns = 5 + (slotCount - slotIndex) / slotCount;
    _animation = Tween<double>(begin: 0, end: endTurns)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..reset()
      ..forward();
  }

  void _showRewardDialog(Map<String, dynamic> reward) {
    final name = (reward['reward_name'] as String?) ?? 'Hadiah';
    final type = (reward['reward_type'] as String?) ?? '';
    final value = (reward['reward_value'] as num?)?.toInt() ?? 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFB923C), Color(0xFFF59E0B)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 20)],
              ),
              child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 20),
            const Text('Selamat! 🎉', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kamu mendapatkan:', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
            const SizedBox(height: 4),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (value > 0) ...[
              const SizedBox(height: 8),
              Text('+$value ${_unit(type)}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<GamificationBloc>().add(const GamificationSpinWheelRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Mantap!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _unit(String type) {
    switch (type) {
      case 'xp':
        return 'XP';
      case 'coins':
        return 'Koin';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Spin Harian', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listenWhen: (p, c) => p.spinResult != c.spinResult,
        listener: (context, state) {
          if (state.spinResult != null && _isSpinning && !_handledResult) {
            _handledResult = true;
            final slots = state.spinWheel?.slots ?? const [];
            final idx = (state.spinResult!['slot_index'] as num?)?.toInt() ?? 0;
            _animateToResult(idx, slots.length);
          }
        },
        builder: (context, state) {
          if (state.spinWheel == null && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final slots = state.spinWheel?.slots ?? const [];
          final canSpin = !(state.spinWheel?.hasSpunToday ?? true) && slots.isNotEmpty;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text('Putar & Menangkan!',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 8),
                  Text(
                    canSpin
                        ? 'Kamu punya 1 putaran gratis hari ini 🎁'
                        : (slots.isEmpty ? 'Roda belum tersedia.' : 'Sudah diputar hari ini. Kembali besok ya!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  _wheel(slots),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!canSpin || _isSpinning || state.status == GamificationStatus.submitting) ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.muted,
                        elevation: canSpin ? 8 : 0,
                        shadowColor: AppColors.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(_isSpinning ? 'MEMUTAR...' : 'PUTAR SEKARANG',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _wheel(List<DailySpinSlot> slots) {
    const dim = 300.0;
    return SizedBox(
      width: dim + 24,
      height: dim + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow base
          Container(
            width: dim + 16,
            height: dim + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 40, spreadRadius: 6)],
            ),
          ),
          // Rotating wheel
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Transform.rotate(angle: _animation.value * 2 * pi, child: child),
            child: slots.isEmpty
                ? const SizedBox(width: dim, height: dim)
                : CustomPaint(
                    size: const Size(dim, dim),
                    painter: _WheelPainter(slots, _sectorColors),
                  ),
          ),
          // Hub
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)],
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 26),
          ),
          // Pointer at top
          Positioned(
            top: -4,
            child: Transform.rotate(
              angle: pi,
              child: Icon(Icons.navigation_rounded, size: 44, color: AppColors.primary,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<DailySpinSlot> slots;
  final List<Color> palette;

  _WheelPainter(this.slots, this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = slots.length;
    final sweep = 2 * pi / n;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final divider = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < n; i++) {
      // Slot i centered at top (-pi/2), spanning ±sweep/2.
      final start = -pi / 2 - sweep / 2 + i * sweep;
      final paintFill = Paint()..color = palette[i % palette.length];
      canvas.drawArc(rect, start, sweep, true, paintFill);
      // Divider line
      final edge = Offset(center.dx + radius * cos(start), center.dy + radius * sin(start));
      canvas.drawLine(center, edge, divider);

      // Label (emoji icon + value) along the bisector.
      final mid = -pi / 2 + i * sweep;
      _drawLabel(canvas, center, radius, mid, slots[i]);
    }

    // Outer ring
    canvas.drawCircle(center, radius - 1,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius, double angle, DailySpinSlot slot) {
    final pos = Offset(center.dx + cos(angle) * radius * 0.6, center.dy + sin(angle) * radius * 0.6);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle + pi / 2); // text points outward

    final icon = slot.icon.isNotEmpty ? slot.icon : '🎁';
    final iconTp = TextPainter(
      text: TextSpan(text: icon, style: const TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    iconTp.paint(canvas, Offset(-iconTp.width / 2, -iconTp.height - 2));

    final label = slot.rewardValue > 0 ? '${slot.rewardValue}' : slot.name;
    final labelTp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 70);
    labelTp.paint(canvas, Offset(-labelTp.width / 2, 4));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => oldDelegate.slots != slots;
}
