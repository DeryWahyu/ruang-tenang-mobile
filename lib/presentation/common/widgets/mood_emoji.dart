import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';

class MoodEmoji extends StatelessWidget {
  final int moodIndex;
  final double size;
  final bool showLabel;
  final bool isSelected;
  final VoidCallback? onTap;

  const MoodEmoji({
    super.key,
    required this.moodIndex,
    this.size = 48,
    this.showLabel = false,
    this.isSelected = false,
    this.onTap,
  });

  // Fallback Material icon when asset images are not available.
  IconData get _fallbackIcon {
    switch (moodIndex) {
      case 1: return Icons.sentiment_very_satisfied_rounded; // Happy
      case 2: return Icons.sentiment_satisfied_rounded;      // Calm
      case 3: return Icons.sentiment_neutral_rounded;        // Neutral
      case 4: return Icons.sentiment_dissatisfied_rounded;   // Sad
      case 5: return Icons.sentiment_very_dissatisfied_rounded; // Cry
      case 6: return Icons.mood_bad_rounded;                 // Angry
      case 7: return Icons.sentiment_dissatisfied_rounded;   // Anxious
      case 8: return Icons.sentiment_very_dissatisfied_rounded; // Stressed
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = Helpers.getMoodLabel(moodIndex);
    final color = Helpers.getMoodColor(moodIndex);
    final assetPath = Helpers.getMoodAsset(moodIndex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Try asset image first, fallback to emoji text
            SizedBox(
              width: size,
              height: size,
              child: assetPath.isNotEmpty
                  ? Image.asset(
                      assetPath,
                      width: size,
                      height: size,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(_fallbackIcon, size: size * 0.82, color: color),
                        );
                      },
                    )
                  : Center(
                      child: Icon(_fallbackIcon, size: size * 0.82, color: color),
                    ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : AppColors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal row of mood emojis for selection
class MoodEmojiPicker extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int>? onMoodSelected;
  final double emojiSize;
  final bool showLabels;

  const MoodEmojiPicker({
    super.key,
    this.selectedMood,
    this.onMoodSelected,
    this.emojiSize = 40,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(8, (index) {
          final moodIndex = index + 1;
          return Padding(
            padding: EdgeInsets.only(right: index < 7 ? 4 : 0),
            child: MoodEmoji(
              moodIndex: moodIndex,
              size: emojiSize,
              showLabel: showLabels,
              isSelected: selectedMood == moodIndex,
              onTap: () => onMoodSelected?.call(moodIndex),
            ),
          );
        }),
      ),
    );
  }
}
