import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';

/// Horizontal / grid picker for the 6 backend-supported moods using modern web assets.
class MoodPicker extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType>? onMoodSelected;
  final bool isGrid;
  final double emojiSize;

  const MoodPicker({
    super.key,
    this.selectedMood,
    this.onMoodSelected,
    this.isGrid = true,
    this.emojiSize = 48, // Slightly larger for images
  });

  @override
  Widget build(BuildContext context) {
    final moods = MoodType.values;

    final items = moods.map((mood) {
      final isSelected = selectedMood == mood;
      return GestureDetector(
        onTap: onMoodSelected == null ? null : () => onMoodSelected!(mood),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? mood.color.withOpacity(0.08)
                : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? mood.color : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: mood.color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Image.asset(
                  isSelected ? mood.activeImagePath : mood.inactiveImagePath,
                  key: ValueKey<bool>(isSelected),
                  width: emojiSize,
                  height: emojiSize,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                mood.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? mood.color : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (isGrid) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: items,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 100, // Fixed width for horizontal items
                    child: item,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
