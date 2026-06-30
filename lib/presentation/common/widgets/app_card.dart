import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double translateY = _isPressed ? -2.0 : 0.0;

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, translateY, 0),
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(AppDimensions.spacingBase),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.color ?? AppColors.card) : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppDimensions.radiusXl,
        ),
        border: widget.border ??
            Border.all(color: AppColors.border, width: 1),
        // Elevasi terpusat & selaras web: shadow-md saat ditekan (interaktif),
        // shadow-sm pada keadaan normal.
        boxShadow: widget.boxShadow ?? (_isPressed ? AppShadows.md : AppShadows.sm),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        // Skala turun halus saat ditekan untuk umpan balik sentuh.
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Card with header and content sections
class AppCardWithHeader extends StatelessWidget {
  final Widget header;
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AppCardWithHeader({
    super.key,
    required this.header,
    required this.content,
    this.padding,
    this.margin,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: margin,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding ??
                const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: trailing != null
                ? Row(
                    children: [
                      Expanded(child: header),
                      trailing!,
                    ],
                  )
                : header,
          ),
          Padding(
            padding: padding ??
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }
}
