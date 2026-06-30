import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
import '../../domain/entities/story.dart';

class StoryCategoryModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final int storyCount;

  const StoryCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.icon = '',
    this.storyCount = 0,
  });

  factory StoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return StoryCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      storyCount: (json['story_count'] as num?)?.toInt() ?? 0,
    );
  }

  StoryCategory toEntity() => StoryCategory(
        id: id,
        name: name,
        slug: slug,
        description: description,
        icon: icon,
        storyCount: storyCount,
      );

  @override
  List<Object?> get props => [id, name, slug, description, icon, storyCount];
}

class StoryAuthorModel extends Equatable {
  final int? id;
  final String name;
  final String avatar;
  final String tierName;
  final String tierColor;

  const StoryAuthorModel({
    this.id,
    required this.name,
    this.avatar = '',
    this.tierName = '',
    this.tierColor = '',
  });

  factory StoryAuthorModel.fromJson(Map<String, dynamic> json) {
    return StoryAuthorModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      tierName: json['tier_name'] as String? ?? '',
      tierColor: json['tier_color'] as String? ?? '',
    );
  }

  StoryAuthor toEntity() => StoryAuthor(
        id: id,
        name: name,
        avatar: avatar,
        tierName: tierName,
        tierColor: tierColor,
      );

  @override
  List<Object?> get props => [id, name, avatar, tierName, tierColor];
}

class StoryModel extends Equatable {
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
  final StoryAuthorModel? author;
  final List<StoryCategoryModel> categories;
  final List<String> tags;
  final bool hasHearted;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const StoryModel({
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

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      hasTriggerWarning: json['has_trigger_warning'] as bool? ?? false,
      triggerWarningText: json['trigger_warning_text'] as String? ?? '',
      status: json['status'] as String? ?? '',
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      heartCount: (json['heart_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      author: json['author'] != null
          ? StoryAuthorModel.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : null,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => StoryCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      hasHearted: json['has_hearted'] as bool? ?? false,
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
      publishedAt: Json.date(json['published_at']),
    );
  }

  Story toEntity() => Story(
        id: id,
        title: title,
        content: content,
        coverImage: coverImage,
        isAnonymous: isAnonymous,
        hasTriggerWarning: hasTriggerWarning,
        triggerWarningText: triggerWarningText,
        status: status,
        viewCount: viewCount,
        heartCount: heartCount,
        commentCount: commentCount,
        isFeatured: isFeatured,
        author: author?.toEntity(),
        categories: categories.map((e) => e.toEntity()).toList(),
        tags: tags,
        hasHearted: hasHearted,
        createdAt: createdAt,
        publishedAt: publishedAt,
      );

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

class StoryCardModel extends Equatable {
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
  final StoryAuthorModel? author;
  final List<StoryCategoryModel> categories;
  final DateTime? publishedAt;

  const StoryCardModel({
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

  factory StoryCardModel.fromJson(Map<String, dynamic> json) {
    return StoryCardModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      hasTriggerWarning: json['has_trigger_warning'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      heartCount: (json['heart_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      author: json['author'] != null
          ? StoryAuthorModel.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : null,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => StoryCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      publishedAt: Json.date(json['published_at']),
    );
  }

  StoryCard toEntity() => StoryCard(
        id: id,
        title: title,
        excerpt: excerpt,
        coverImage: coverImage,
        isAnonymous: isAnonymous,
        hasTriggerWarning: hasTriggerWarning,
        status: status,
        heartCount: heartCount,
        commentCount: commentCount,
        isFeatured: isFeatured,
        author: author?.toEntity(),
        categories: categories.map((e) => e.toEntity()).toList(),
        publishedAt: publishedAt,
      );

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



class StoryCommentModel extends Equatable {
  final String id;
  final String content;
  final int heartCount;
  final StoryAuthorModel? author;
  final bool hasHearted;
  final bool isHidden;
  final DateTime createdAt;

  const StoryCommentModel({
    required this.id,
    required this.content,
    this.heartCount = 0,
    this.author,
    this.hasHearted = false,
    this.isHidden = false,
    required this.createdAt,
  });

  factory StoryCommentModel.fromJson(Map<String, dynamic> json) {
    return StoryCommentModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      heartCount: (json['heart_count'] as num?)?.toInt() ?? 0,
      author: json['author'] != null
          ? StoryAuthorModel.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : null,
      hasHearted: json['has_hearted'] as bool? ?? false,
      isHidden: json['is_hidden'] as bool? ?? false,
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
    );
  }

  StoryComment toEntity() => StoryComment(
        id: id,
        content: content,
        heartCount: heartCount,
        author: author?.toEntity(),
        hasHearted: hasHearted,
        isHidden: isHidden,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, content, heartCount, author, hasHearted, isHidden, createdAt];
}