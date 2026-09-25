import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Uses the same badge artwork and key-to-image mapping as the member web UI.
/// The surrounding circle and earned state are styled by the caller.
class GamificationBadgeIcon extends StatelessWidget {
  final String badgeKey;
  final String category;
  final bool earned;
  final double size;

  const GamificationBadgeIcon({
    super.key,
    required this.badgeKey,
    required this.category,
    required this.earned,
    this.size = 40,
  });

  static const _badgeAssets = <String, String>{
    'streak_7': 'streak-7',
    'streak_14': 'streak-14',
    'streak_30': 'streak-30',
    'streak_60': 'streak-60',
    'streak_100': 'streak-100',
    'activities_10': 'activities-10',
    'activities_50': 'activities-50',
    'activities_100': 'activities-100',
    'activities_500': 'activities-500',
    'first_article': 'first-article',
    'articles_5': 'articles-5',
    'helpful_commenter': 'helpful-commenter',
    'top_contributor': 'top-contributor',
    'level_5': 'level-5',
    'level_10': 'level-10',
    'xp_1000': 'xp-1000',
    'xp_5000': 'xp-5000',
    'xp_10000': 'xp-10000',
    'beta_tester': 'beta-tester',
    'community_mentor': 'community-mentor',
    'guardian': 'guardian',
    'first_story': 'first-story',
    'stories_3': 'stories-3',
    'story_100_hearts': 'story-100-hearts',
  };

  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  IconData get _fallbackIcon {
    final key = '$badgeKey $category'.toLowerCase();
    if (key.contains('streak') ||
        key.contains('flame') ||
        key.contains('fire')) {
      return Icons.local_fire_department_rounded;
    }
    if (key.contains('xp') || key.contains('energy') || key.contains('boost')) {
      return Icons.bolt_rounded;
    }
    if (key.contains('article') ||
        key.contains('book') ||
        key.contains('content')) {
      return Icons.auto_stories_rounded;
    }
    if (key.contains('journal') ||
        key.contains('write') ||
        key.contains('reflection')) {
      return Icons.edit_note_rounded;
    }
    if (key.contains('chat') ||
        key.contains('message') ||
        key.contains('conversation')) {
      return Icons.chat_bubble_outline_rounded;
    }
    if (key.contains('community') ||
        key.contains('forum') ||
        key.contains('comment')) {
      return Icons.forum_outlined;
    }
    if (key.contains('mood') ||
        key.contains('wellness') ||
        key.contains('mental')) {
      return Icons.psychology_alt_rounded;
    }
    if (key.contains('story') || key.contains('inspire')) {
      return Icons.auto_stories_rounded;
    }
    if (key.contains('reward') ||
        key.contains('gift') ||
        key.contains('unlock')) {
      return Icons.card_giftcard_rounded;
    }
    if (key.contains('target') ||
        key.contains('goal') ||
        key.contains('mission')) {
      return Icons.flag_rounded;
    }
    if (key.contains('level') ||
        key.contains('achievement') ||
        key.contains('badge')) {
      return Icons.workspace_premium_rounded;
    }
    return Icons.workspace_premium_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _badgeAssets[badgeKey.trim().toLowerCase()];
    if (asset == null) {
      return Icon(
        _fallbackIcon,
        size: size * 0.72,
        color: earned ? const Color(0xFFD97706) : AppColors.gray400,
      );
    }

    Widget image = Image.asset(
      'assets/images/badges/$asset.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (!earned) {
      image = Opacity(
        opacity: 0.5,
        child: ColorFiltered(colorFilter: _grayscale, child: image),
      );
    }
    return image;
  }
}
