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
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(url);
    final media = MediaQuery.of(context);

    Widget content;
    if (resolved == null) {
      content = _fallback();
    } else {
      // Target lebar dekode = lebar tampil × devicePixelRatio (dibatasi agar
      // tidak menahan resolusi lebih besar dari yang dibutuhkan layar).
      int? cacheWidth;
      if (width != null && width!.isFinite) {
        cacheWidth = (width! * media.devicePixelRatio).round();
      }

      content = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        maxWidthDiskCache: cacheWidth,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _fallback(),
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.muted,
    );
  }

  Widget _fallback() {
    final iconSize = (width != null && width!.isFinite) ? (width! * 0.4).clamp(16.0, 48.0) : 24.0;
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.muted,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: fallbackColor ?? AppColors.mutedForeground, size: iconSize),
    );
  }
}
