import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool showCancel;
  final bool isLoading;
  final IconData? icon;
  final Color? iconColor;

  const AppDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCancel = true,
    this.isLoading = false,
    this.icon,
    this.iconColor,
  });

  /// Show a confirmation dialog
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Show an alert dialog
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmLabel: buttonLabel,
        showCancel: false,
        icon: icon,
        iconColor: iconColor,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String title = 'Terjadi Kesalahan',
  }) {
    return showAlert(
      context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.destructive,
    );
  }

  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String title = 'Berhasil',
  }) {
    return showAlert(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingBase),
            ],
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppDimensions.spacingBase),
              content!,
            ],
            const SizedBox(height: AppDimensions.spacingXl),
            Row(
              children: [
                if (showCancel) ...[
                  Expanded(
                    child: AppButton.outline(
                      label: cancelLabel ?? 'Batal',
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                ],
                Expanded(
                  child: AppButton(
                    label: confirmLabel ?? 'OK',
                    variant: isDestructive
                        ? AppButtonVariant.destructive
                        : AppButtonVariant.primary,
                    isLoading: isLoading,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
