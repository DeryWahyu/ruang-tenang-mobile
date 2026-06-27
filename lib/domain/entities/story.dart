import 'package:equatable/equatable.dart';

class StoryCategory extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final int storyCount;

  const StoryCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.icon = '',
    this.storyCount = 0,
  });

  @override
  List<Object?> get props => [id, name, slug, description, icon, storyCount];
}

class StoryAuthor extends Equatable {
  final int? id; // nullable to respect anonymity
  final String name;
  final String avatar;
  final String tierName;
  final String tierColor;

  const StoryAuthor({
    this.id,
    required this.name,
    this.avatar = '',
    this.tierName = '',
    this.tierColor = '',
  });

  @override
  List<Object?> get props => [id, name, avatar, tierName, tierColor];
}

class Story extends Equatable {
  final String id;
  final String title;
  final String content;
  final String coverImage;
  final bool isAnonymous;
  final bool hasTriggerWarning;
  final String triggerWarningText;
  final String status;
  final int viewCount;
  final int heartCount;
  final int commentCount;
  final bool isFeatured;
  final StoryAuthor? author;
  final List<StoryCategory> categories;
  final List<String> tags;
  final bool hasHearted;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const Story({
    required this.id,
    required this.title,
    required this.content,
    this.coverImage = '',
    this.isAnonymous = false,
    this.hasTriggerWarning = false,
    this.triggerWarningText = '',
    required this.status,
    this.viewCount = 0,
    this.heartCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.author,
    this.categories = const [],
    this.tags = const [],
    this.hasHearted = false,
    required this.createdAt,
    this.publishedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        coverImage,
        isAnonymous,
        hasTriggerWarning,
        triggerWarningText,
        status,
        viewCount,
        heartCount,
        commentCount,
        isFeatured,
        author,
        categories,
        tags,
        hasHearted,
        createdAt,
        publishedAt,
      ];
}

class StoryCard extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final String coverImage;
  final bool isAnonymous;
  final bool hasTriggerWarning;
  final String status;
  final int heartCount;
  final int commentCount;
  final bool isFeatured;
  final StoryAuthor? author;
  final List<StoryCategory> categories;
  final DateTime? publishedAt;

  const StoryCard({
    required this.id,
    required this.title,
    required this.excerpt,
    this.coverImage = '',
    this.isAnonymous = false,
    this.hasTriggerWarning = false,
    this.status = '',
    this.heartCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.author,
    this.categories = const [],
    this.publishedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        excerpt,
        coverImage,
        isAnonymous,
        hasTriggerWarning,
        status,
        heartCount,
        commentCount,
        isFeatured,
        author,
        categories,
        publishedAt,
      ];
}

class StoryComment extends Equatable {
  final String id;
  final String content;
  final int heartCount;
  final StoryAuthor? author;
  final bool hasHearted;
  final bool isHidden;
  final DateTime createdAt;

  const StoryComment({
    required this.id,
    required this.content,
    this.heartCount = 0,
    this.author,
    this.hasHearted = false,
    this.isHidden = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        heartCount,
        author,
        hasHearted,
        isHidden,
        createdAt,
      ];
}

class StoryStats extends Equatable {
  final int totalStories;
  final int approvedStories;
  final int pendingStories;
  final int totalHearts;
  final int totalViews;
  final int totalComments;
  final int storiesThisMonth;
  final int maxStoriesPerMonth;
  final bool canSubmitMore;

  const StoryStats({
    this.totalStories = 0,
    this.approvedStories = 0,
    this.pendingStories = 0,
    this.totalHearts = 0,
    this.totalViews = 0,
    this.totalComments = 0,
    this.storiesThisMonth = 0,
    this.maxStoriesPerMonth = 0,
    this.canSubmitMore = true,
  });

  @override
  List<Object?> get props => [
        totalStories,
        approvedStories,
        pendingStories,
        totalHearts,
        totalViews,
        totalComments,
        storiesThisMonth,
        maxStoriesPerMonth,
        canSubmitMore,
      ];
}
