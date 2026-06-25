import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// Notification count badge (red circle with number)
class AppBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color? color;
  final Color? textColor;
  final Widget? child;

  const AppBadge({
    super.key,
    required this.count,
    this.size = 18,
    this.color,
    this.textColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: _buildBadge(context),
            ),
        ],
      );
    }
    return _buildBadge(context);
  }

  Widget _buildBadge(BuildContext context) {
    final displayText = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.notification,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.card, width: 1.5),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Status badge (colored label)
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  const AppStatusBadge.success({
    super.key,
    required this.label,
    this.icon,
  })  : backgroundColor = AppColors.successLight,
        textColor = const Color(0xFF166534);

  const AppStatusBadge.warning({
    super.key,
    required this.label,
    this.icon,
  })  : backgroundColor = AppColors.warningLight,
        textColor = const Color(0xFF92400E);

  const AppStatusBadge.error({
    super.key,
    required this.label,
    this.icon,
  })  : backgroundColor = const Color(0xFFFEE2E2),
        textColor = const Color(0xFFB91C1C);

  const AppStatusBadge.info({
    super.key,
    required this.label,
    this.icon,
  })  : backgroundColor = AppColors.infoLight,
        textColor = const Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? AppColors.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
