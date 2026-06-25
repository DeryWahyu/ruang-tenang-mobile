import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? maxHeight;
  final bool showDragHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.maxHeight,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding,
  });

  /// Show a bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    double? maxHeight,
    bool isDismissible = true,
    bool showDragHandle = true,
    bool showCloseButton = false,
    bool isScrollControlled = true,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
      ),
      builder: (context) => AppBottomSheet(
        title: title,
        maxHeight: maxHeight,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        padding: padding,
        child: child,
      ),
    );
  }

  /// Show a bottom sheet with a list of options
  static Future<T?> showOptions<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return show<T>(
      context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: option.icon != null
                ? Icon(option.icon, color: option.isDestructive ? AppColors.destructive : AppColors.foreground)
                : null,
            title: Text(
              option.label,
              style: TextStyle(
                color: option.isDestructive ? AppColors.destructive : AppColors.foreground,
              ),
            ),
            subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
            onTap: () => Navigator.of(context).pop(option.value),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDragHandle)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
          ),
        Flexible(
          child: Padding(
            padding: padding ??
                const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ),
      ],
    );

    if (maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: contentWidget,
      );
    }

    return contentWidget;
  }
}

class BottomSheetOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool isDestructive;

  const BottomSheetOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.isDestructive = false,
  });
}
