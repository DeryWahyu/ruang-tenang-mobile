import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';

/// Horizontal / grid picker for the 6 backend-supported moods.
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
    this.emojiSize = 40,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? mood.color.withValues(alpha: 0.12)
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isSelected ? mood.color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mood.emoji,
                style: TextStyle(fontSize: emojiSize),
              ),
              const SizedBox(height: 6),
              Text(
                mood.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
        mainAxisSpacing: AppDimensions.spacingSm,
        crossAxisSpacing: AppDimensions.spacingSm,
        childAspectRatio: 1.1,
        children: items,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
                  child: item,
                ))
            .toList(),
      ),
    );
  }
}
