import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final bool showCheckmark;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.selectedTextColor,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedColor ?? AppColors.primary)
        : AppColors.muted;
    final fgColor = isSelected
        ? (selectedTextColor ?? AppColors.primaryForeground)
        : AppColors.foreground;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark && isSelected) ...[
              Icon(Icons.check, size: 14, color: fgColor),
              const SizedBox(width: 4),
            ],
            if (icon != null && !(showCheckmark && isSelected)) ...[
              Icon(icon, size: 14, color: fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable chip list
class AppChipGroup extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final List<String>? selectedItems;
  final ValueChanged<String>? onSelected;
  final bool multiSelect;
  final EdgeInsetsGeometry? padding;

  const AppChipGroup({
    super.key,
    required this.items,
    this.selectedItem,
    this.selectedItems,
    this.onSelected,
    this.multiSelect = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items.map((item) {
          final isSelected = multiSelect
              ? (selectedItems?.contains(item) ?? false)
              : item == selectedItem;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppChip(
              label: item,
              isSelected: isSelected,
              onTap: () => onSelected?.call(item),
            ),
          );
        }).toList(),
      ),
    );
  }
}
