import 'package:flutter/material.dart';
import '../../../core/utils/media_url.dart';
import 'app_network_image.dart';

/// Renders a level/tier badge. The backend stores the level badge as an image
/// URL (e.g. `/storage/badge-image/3.png`), but some sources still use
/// an emoji. This widget handles both, with a medal fallback on error/empty.
class LevelBadge extends StatelessWidget {
  final String? icon;
  final double size;
  final Color? fallbackColor;

  const LevelBadge({
    super.key,
    required this.icon,
    this.size = 44,
    this.fallbackColor,
  });

  bool get _looksLikeImage {
    final raw = icon ?? '';
    return raw.startsWith('http') ||
        raw.startsWith('/') ||
        raw.contains('/uploads') ||
        raw.endsWith('.png') ||
        raw.endsWith('.jpg') ||
        raw.endsWith('.jpeg') ||
        raw.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final raw = icon ?? '';

    if (_looksLikeImage) {
      final url = resolveMediaUrl(raw);
      if (url != null) {
        return AppNetworkImage(
          url: url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          fallbackIcon: Icons.military_tech_rounded,
          fallbackColor: fallbackColor ?? Colors.amber.shade600,
          backgroundColor: Colors.transparent,
        );
      }
      return _fallback();
    }

    // Konsisten dengan web: nilai non-image diperlakukan sebagai emoji/teks
    // pendek dan dirender apa adanya (web memakai `<span>{icon}</span>`).
    if (raw.isNotEmpty) {
      return Center(
        child: Text(raw, style: TextStyle(fontSize: size * 0.62)),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Icon(
      Icons.military_tech_rounded,
      size: size * 0.78,
      color: fallbackColor ?? Colors.amber.shade600,
    );
  }
}
