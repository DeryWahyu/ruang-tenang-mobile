import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';
import 'dart:math' as math;

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
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCirc,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin(int slotIndex, int totalSlots) {
    final sliceAngle = 2 * math.pi / totalSlots;
    // Calculate final rotation to land exactly on the target slot
    // We add multiple full rotations (e.g. 5) plus the specific offset
    final targetOffset = (math.pi / 2) - (slotIndex * sliceAngle) - (sliceAngle / 2);
    final targetRotation = _currentRotation + (5 * 2 * math.pi) + targetOffset;

    _spinAnimation = Tween<double>(begin: _currentRotation, end: targetRotation).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCirc),
    );

    _spinController.forward(from: 0).then((_) {
      _currentRotation = targetRotation % (2 * math.pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin Harian'),
        centerTitle: true,
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listener: (context, state) {
          if (state.spinResult != null && state.spinWheel != null) {
            _spin(state.spinResult!['slot_index'], state.spinWheel!.slots.length);
            
            // Show result after animation finishes
            Future.delayed(const Duration(seconds: 4), () {
              _showRewardDialog(context, state.spinResult!);
            });
          }
        },
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == GamificationStatus.failure && state.spinWheel == null) {
            return Center(child: Text(state.errorMessage));
          }
          if (state.spinWheel == null) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          final wheel = state.spinWheel!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Putar roda untuk mendapatkan hadiah!', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                
                // The Wheel
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _spinAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinAnimation.status == AnimationStatus.forward ? _spinAnimation.value : _currentRotation,
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 8),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: ClipOval(
                            child: CustomPaint(
                              painter: _WheelPainter(slots: wheel.slots),
                              size: const Size(300, 300),
                            ),
                          ),
                        ),
                      ),
                      
                      // The Pointer
                      Positioned(
                        top: -10,
                        child: Icon(Icons.arrow_drop_down_circle, size: 40, color: AppColors.primary),
                      ),
                      
                      // Center Button
                      GestureDetector(
                        onTap: (wheel.hasSpunToday || state.status == GamificationStatus.submitting)
                            ? null
                            : () => context.read<GamificationBloc>().add(const GamificationSpinRequested()),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: wheel.hasSpunToday ? AppColors.muted : AppColors.primary,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: Center(
                            child: state.status == GamificationStatus.submitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  wheel.hasSpunToday ? 'Besok\nLagi' : 'SPIN',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRewardDialog(BuildContext context, Map<String, dynamic> reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selamat!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward['reward_icon'] ?? '🎁', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Kamu mendapatkan:'),
            const SizedBox(height: 8),
            Text(reward['reward_name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<GamificationBloc>().add(const GamificationSpinWheelRequested());
              },
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<dynamic> slots;
  _WheelPainter({required this.slots});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = 2 * math.pi / slots.length;

    final colors = [AppColors.red50, AppColors.red100, AppColors.red200, AppColors.warningLight];

    for (var i = 0; i < slots.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sliceAngle,
        sliceAngle,
        true,
        paint,
      );

      // Draw Text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * sliceAngle + sliceAngle / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: slots[i].name,
          style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(radius / 2, -textPainter.height / 2));
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}