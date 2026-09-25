import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';

/// Gambar jaringan yang dioptimalkan, dipakai bersama di seluruh aplikasi.
///
/// Optimasi performa & memori:
/// - **Disk + memory cache** (lewat `cached_network_image`) → tidak mengunduh
///   ulang gambar yang sama saat berpindah layar.
/// - **Downscale saat decode** (`memCacheWidth`/`maxWidthDiskCache`) → gambar
///   besar di-decode pada resolusi sesuai ukuran tampil, menghemat RAM &
///   mempercepat render (mengurangi jank).
/// - **Resolusi URL otomatis** via [resolveMediaUrl] (path relatif → absolut).
///
/// Gunakan ini menggantikan `Image.network` mentah agar konsisten & efisien.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? cacheBuster;

  /// Ikon fallback saat URL kosong / gagal dimuat.
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.cacheBuster,
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolved = resolveMediaUrl(url, cacheBuster: cacheBuster);
        final media = MediaQuery.of(context);
        final displayWidth = _boundedDimension(
          width,
          constraints.maxWidth,
          media.size.width,
        );
        final displayHeight = _boundedDimension(
          height,
          constraints.maxHeight,
          null,
        );
        final cacheWidth = _cacheDimension(
          displayWidth,
          media.devicePixelRatio,
        );
        final cacheHeight = _cacheDimension(
          displayHeight,
          media.devicePixelRatio,
        );

        Widget content;
        if (resolved == null) {
          content = _fallback();
        } else {
          content = CachedNetworkImage(
            imageUrl: resolved,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: cacheWidth,
            memCacheHeight: cacheHeight,
            maxWidthDiskCache: cacheWidth,
            maxHeightDiskCache: cacheHeight,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (_, _) => _placeholder(),
            errorWidget: (_, _, _) => _fallback(),
          );
        }

        if (borderRadius != null) {
          content = ClipRRect(borderRadius: borderRadius!, child: content);
        }
        return content;
      },
    );
  }

  double? _boundedDimension(
    double? requested,
    double constraint,
    double? fallback,
  ) {
    if (requested != null && requested.isFinite && requested > 0) {
      if (constraint.isFinite && constraint > 0 && constraint < requested) {
        return constraint;
      }
      return requested;
    }
    if (constraint.isFinite && constraint > 0) return constraint;
    return fallback;
  }

  int? _cacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * devicePixelRatio).round().clamp(1, 2048).toInt();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.muted,
    );
  }

  Widget _fallback() {
    final iconSize = (width != null && width!.isFinite)
        ? (width! * 0.4).clamp(16.0, 48.0)
        : 24.0;
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.muted,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: fallbackColor ?? AppColors.mutedForeground,
        size: iconSize,
      ),
    );
  }
}
