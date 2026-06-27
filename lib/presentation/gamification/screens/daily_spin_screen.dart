import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
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
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        final state = context.read<GamificationBloc>().state;
        if (state.spinResult != null) {
          _showRewardDialog(state.spinResult);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);
    // Add extra rotations plus random
    final randomRotations = Random().nextDouble() + 5.0; 
    _animationController.reset();
    _animation = Tween<double>(begin: 0, end: randomRotations).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    context.read<GamificationBloc>().add(const GamificationSpinRequested());
  }

  void _showRewardDialog(reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration_rounded, color: Colors.orange, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Hore!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Kamu mendapatkan:\n${reward['reward_name']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.mutedForeground, height: 1.5),
              ),
              if (reward['reward_type'] == 'exp') ...[
                const SizedBox(height: 16),
                Text(
                  '+${reward['reward_value']} XP',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<GamificationBloc>().add(const GamificationSpinWheelRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spin Harian', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final canSpin = !(state.spinWheel?.hasSpunToday ?? true);

          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Putar & Menangkan!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.foreground),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      canSpin
                          ? 'Kamu memiliki 1 kesempatan putaran gratis hari ini.'
                          : 'Kamu sudah memutar hari ini. Kembali lagi besok!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.mutedForeground.withOpacity(0.8), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Wheel Graphic
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.card,
                          boxShadow: [
                            BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animation.value * 2 * pi,
                              child: child,
                            );
                          },
                          child: Stack(
                            children: [
                              // Background slices
                              ...List.generate(6, (index) {
                                return Transform.rotate(
                                  angle: index * (pi / 3),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ClipPath(
                                      clipper: _SliceClipper(),
                                      child: Container(
                                        width: 160,
                                        height: 160,
                                        color: index % 2 == 0 ? Colors.orange.shade400 : Colors.amber.shade300,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Center peg
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                  ),
                                  child: const Icon(Icons.star_rounded, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Top Pointer Indicator
                      Positioned(
                        top: -10,
                        child: Transform.rotate(
                          angle: pi,
                          child: const Icon(Icons.navigation_rounded, size: 48, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 64),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!canSpin || _isSpinning || state.status == GamificationStatus.submitting)
                            ? null
                            : _startSpin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.muted,
                          elevation: canSpin ? 8 : 0,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(
                          _isSpinning ? 'MEMUTAR...' : 'PUTAR SEKARANG',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
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
}

class _SliceClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
