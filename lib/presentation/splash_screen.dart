import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/bloc/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _animationInitialized = false;
  bool _authCheckStarted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationInitialized) return;
    _animationInitialized = true;
    unawaited(_prepareSplashAndCheckAuth());
    if (MediaQuery.disableAnimationsOf(context)) {
      _animController.value = 1;
    } else {
      _animController.forward();
    }
  }

  Future<void> _prepareSplashAndCheckAuth() async {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mascotWidth = math.min(screenWidth * 0.68, 280.0).toDouble();

    await Future.wait<void>([
      _precacheSplashImage(
        ResizeImage(
          const AssetImage('assets/icon/app_icon.png'),
          width: (106 * devicePixelRatio).round(),
        ),
      ),
      _precacheSplashImage(
        ResizeImage(
          const AssetImage('assets/images/mascot/chat-welcome.webp'),
          width: (mascotWidth * devicePixelRatio).round(),
        ),
      ),
      Future<void>.delayed(const Duration(milliseconds: 500)),
    ]);

    if (!mounted || _authCheckStarted) return;
    _authCheckStarted = true;
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  Future<void> _precacheSplashImage(ImageProvider<Object> provider) async {
    try {
      await precacheImage(provider, context);
    } catch (_) {
      // Continue to auth even if a bundled splash asset cannot be decoded.
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final mascotHeight = math.min(screenSize.height * 0.36, 310.0).toDouble();
    final mascotWidth = math.min(screenSize.width * 0.68, 280.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF2EE),
                  Color(0xFFFFFCF8),
                  Color(0xFFFFE9E5),
                ],
                stops: [0, 0.52, 1],
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.17,
            left: -90,
            child: _glow(220, const Color(0xFFFFC5BD).withValues(alpha: 0.28)),
          ),
          Positioned(
            right: -110,
            bottom: screenSize.height * 0.12,
            child: _glow(300, const Color(0xFFFFBBAF).withValues(alpha: 0.24)),
          ),
          Positioned(
            right: -56,
            bottom: -22,
            child: IgnorePointer(
              child: SizedBox(
                width: mascotWidth,
                height: mascotHeight,
                child: Image.asset(
                  'assets/images/mascot/chat-welcome.webp',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  cacheWidth: (mascotWidth * devicePixelRatio).round(),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
              child: Column(
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogoBadge(),
                          const SizedBox(height: 22),
                          Text(
                            AppConstants.appName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.appTagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.gray600,
                                  letterSpacing: 0.1,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildLoadingIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Container(
      width: 174,
      height: 174,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.88),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.red700.withValues(alpha: 0.12),
            blurRadius: 42,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.red50.withValues(alpha: 0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: 106,
            height: 106,
            fit: BoxFit.contain,
            cacheWidth: (106 * MediaQuery.devicePixelRatioOf(context)).round(),
            semanticLabel: 'Logo Ruang Tenang',
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.spa_rounded,
              size: 76,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Menyiapkan...',
            style: TextStyle(
              color: AppColors.gray700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
