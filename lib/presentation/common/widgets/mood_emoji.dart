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

  // Fallback emoji characters when asset images are not available
  String get _emojiChar {
    switch (moodIndex) {
      case 1: return '\u{1F60A}'; // Happy
      case 2: return '\u{1F60C}'; // Calm
      case 3: return '\u{1F610}'; // Neutral
      case 4: return '\u{1F614}'; // Sad
      case 5: return '\u{1F622}'; // Cry
      case 6: return '\u{1F621}'; // Angry
      case 7: return '\u{1F630}'; // Anxious
      case 8: return '\u{1F62B}'; // Stressed
      default: return '\u{2753}';
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
                          child: Text(
                            _emojiChar,
                            style: TextStyle(fontSize: size * 0.7),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        _emojiChar,
                        style: TextStyle(fontSize: size * 0.7),
                      ),
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
