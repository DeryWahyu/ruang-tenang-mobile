import 'package:flutter/material.dart';

/// A soft, modern gradient backdrop with subtle colored glows. Used app-wide
/// (behind the navigator) so screens no longer look plain white. Screens with
/// a transparent [Scaffold] background let this show through.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF1F2), // soft rose
            Color(0xFFF9FAFB), // background
            Color(0xFFFFF7ED), // soft warm accent
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, right: -70, child: _blob(const Color(0xFFEF4444), 0.10, 240)),
          Positioned(top: 170, left: -80, child: _blob(const Color(0xFFF97316), 0.08, 220)),
          Positioned(bottom: -110, right: -50, child: _blob(const Color(0xFFEF4444), 0.06, 260)),
          // Content (non-positioned → sizes the stack, painted on top).
          child,
        ],
      ),
    );
  }

  Widget _blob(Color color, double opacity, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
