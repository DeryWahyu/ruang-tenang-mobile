import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  /// Network error preset
  const AppErrorWidget.network({
    super.key,
    this.onRetry,
  })  : title = 'Tidak Ada Koneksi',
        message = 'Pastikan perangkat terhubung ke internet dan coba lagi.',
        retryLabel = 'Coba Lagi',
        icon = Icons.wifi_off_rounded;

  /// Server error preset
  const AppErrorWidget.server({
    super.key,
    this.onRetry,
  })  : title = 'Terjadi Kesalahan',
        message = 'Server sedang mengalami gangguan. Silakan coba lagi nanti.',
        retryLabel = 'Coba Lagi',
        icon = Icons.cloud_off_rounded;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.foreground,
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel ?? 'Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
