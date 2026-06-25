import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive, text }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? child;

  const AppButton({
    super.key,
    this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  });

  // Named constructors for quick access
  const AppButton.primary({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.destructive({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.destructive;

  const AppButton.text({
    super.key,
    this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  }) : variant = AppButtonVariant.text;

  double get _height {
    switch (size) {
      case AppButtonSize.sm:
        return AppDimensions.buttonHeightSm;
      case AppButtonSize.md:
        return AppDimensions.buttonHeightMd;
      case AppButtonSize.lg:
        return AppDimensions.buttonHeightLg;
    }
  }

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.sm:
        return 12;
      case AppButtonSize.md:
      case AppButtonSize.lg:
        return 14;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.sm:
        return 16;
      case AppButtonSize.md:
        return 18;
      case AppButtonSize.lg:
        return 20;
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return AppColors.destructive;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primaryForeground;
      case AppButtonVariant.secondary:
        return AppColors.secondaryForeground;
      case AppButtonVariant.outline:
        return AppColors.foreground;
      case AppButtonVariant.ghost:
        return AppColors.foreground;
      case AppButtonVariant.text:
        return AppColors.primary;
      case AppButtonVariant.destructive:
        return AppColors.destructiveForeground;
    }
  }

  BorderSide? get _borderSide {
    if (variant == AppButtonVariant.outline) {
      return const BorderSide(color: AppColors.border, width: 1);
    }
    return BorderSide.none;
  }

  double get _elevation {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return AppDimensions.elevationSm;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildChild();

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _backgroundColor.withValues(alpha: 0.5);
        }
        if (states.contains(WidgetState.pressed)) {
          if (variant == AppButtonVariant.ghost) return AppColors.secondary;
          return _backgroundColor.withValues(alpha: 0.9);
        }
        return _backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _foregroundColor.withValues(alpha: 0.5);
        }
        return _foregroundColor;
      }),
      elevation: WidgetStatePropertyAll(_elevation),
      padding: WidgetStatePropertyAll(_padding),
      minimumSize: WidgetStatePropertyAll(
        Size(isFullWidth ? double.infinity : 0, _height),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: _borderSide ?? BorderSide.none,
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (variant == AppButtonVariant.ghost ||
            variant == AppButtonVariant.text) {
          return AppColors.secondary.withValues(alpha: 0.5);
        }
        return null;
      }),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );

    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: buttonChild,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foregroundColor,
        ),
      );
    }

    if (child != null) return child!;

    final textWidget = Text(
      label ?? '',
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (prefixIcon == null && suffixIcon == null) return textWidget;

    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: _iconSize),
          const SizedBox(width: 8),
        ],
        textWidget,
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(suffixIcon, size: _iconSize),
        ],
      ],
    );
  }
}

/// Icon-only button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = AppDimensions.buttonIconSize,
    this.iconSize = AppDimensions.iconLg,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.foreground,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
