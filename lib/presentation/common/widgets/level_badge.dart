import 'package:flutter/material.dart';
import '../../../core/utils/media_url.dart';

/// Renders a level/tier badge. The backend stores the level badge as an image
/// URL (e.g. `/uploads/images/badge_level_3.png`), but some sources still use
/// an emoji. This widget handles both, with a medal fallback on error/empty.
class LevelBadge extends StatelessWidget {
  final String? icon;
  final double size;
  final Color? fallbackColor;

  const LevelBadge({super.key, required this.icon, this.size = 44, this.fallbackColor});

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
        return Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      }
      return _fallback();
    }

    if (raw.isNotEmpty) {
      // Treat as emoji / short text.
      return Center(child: Text(raw, style: TextStyle(fontSize: size * 0.62)));
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
