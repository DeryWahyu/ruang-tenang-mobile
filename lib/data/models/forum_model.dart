import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
import '../../domain/entities/forum.dart';

class ForumCategoryModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final DateTime createdAt;

  const ForumCategoryModel({
    required this.id,
    required this.name,
    this.slug = '',
    required this.createdAt,
  });

  factory ForumCategoryModel.fromJson(Map<String, dynamic> json) {
    return ForumCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
    );
  }

  ForumCategory toEntity() => ForumCategory(
        id: id,
        name: name,
        slug: slug,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, name, slug, createdAt];
}

class UserBriefModel extends Equatable {
  final int id;
  final String name;
  final String avatar;
  final int exp;

  const UserBriefModel({
    required this.id,
    required this.name,
    this.avatar = '',
    this.exp = 0,
  });

  factory UserBriefModel.fromJson(Map<String, dynamic> json) {
    return UserBriefModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      exp: (json['exp'] as num?)?.toInt() ?? 0,
    );
  }

  UserBrief toEntity() => UserBrief(
        id: id,
        name: name,
        avatar: avatar,
        exp: exp,
      );

  @override
  List<Object?> get props => [id, name, avatar, exp];
}

class ForumThreadModel extends Equatable {
  final int id;
  final int userId;
  final int? categoryId;
  final String slug;
  final String title;
  final String content;
  final bool isFlagged;
  final bool hasAcceptedAnswer;
  final int repliesCount;
  final int likesCount;
  final bool isLiked;
  final UserBriefModel? user;
  final ForumCategoryModel? category;
  final String createdAt;
  final String updatedAt;

  const ForumThreadModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.slug,
    required this.title,
    this.content = '',
    this.isFlagged = false,
    this.hasAcceptedAnswer = false,
    this.repliesCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.user,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumThreadModel.fromJson(Map<String, dynamic> json) {
    return ForumThreadModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt(),
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isFlagged: json['is_flagged'] as bool? ?? false,
      hasAcceptedAnswer: json['has_accepted_answer'] as bool? ?? false,
      repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      user: json['user'] != null
          ? UserBriefModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      category: json['category'] != null
          ? ForumCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  ForumThread toEntity() => ForumThread(
        id: id,
        userId: userId,
        categoryId: categoryId,
        slug: slug,
        title: title,
        content: content,
        isFlagged: isFlagged,
        hasAcceptedAnswer: hasAcceptedAnswer,
        repliesCount: repliesCount,
        likesCount: likesCount,
        isLiked: isLiked,
        user: user?.toEntity(),
        category: category?.toEntity(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [
        id, userId, categoryId, slug, title, content,
        isFlagged, hasAcceptedAnswer, repliesCount, likesCount, isLiked,
        user, category, createdAt, updatedAt,
      ];
}

class ForumPostModel extends Equatable {
  final int id;
  final int forumId;
  final int userId;
  final String content;
  final bool isAcceptedAnswer;
  final bool isCommunityFavorite;
  final int upvotesCount;
  final int downvotesCount;
  final int netVotes;
  final bool hasUserVoted;
  final String? userVoteType;
  final bool isAutoHidden;
  final bool isFlagged;
  final String createdAt;
  final String updatedAt;
  final UserBriefModel? user;

  const ForumPostModel({
    required this.id,
    required this.forumId,
    required this.userId,
    required this.content,
    this.isAcceptedAnswer = false,
    this.isCommunityFavorite = false,
    this.upvotesCount = 0,
    this.downvotesCount = 0,
    this.netVotes = 0,
    this.hasUserVoted = false,
    this.userVoteType,
    this.isAutoHidden = false,
    this.isFlagged = false,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      forumId: (json['forum_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
      isAcceptedAnswer: json['is_accepted_answer'] as bool? ?? false,
      isCommunityFavorite: json['is_community_favorite'] as bool? ?? false,
      upvotesCount: (json['upvotes_count'] as num?)?.toInt() ?? 0,
      downvotesCount: (json['downvotes_count'] as num?)?.toInt() ?? 0,
      netVotes: (json['net_votes'] as num?)?.toInt() ?? 0,
      hasUserVoted: json['has_user_voted'] as bool? ?? false,
      userVoteType: json['user_vote_type'] as String?,
      isAutoHidden: json['is_auto_hidden'] as bool? ?? false,
      isFlagged: json['is_flagged'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      user: json['user'] != null
          ? UserBriefModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  ForumPost toEntity() => ForumPost(
        id: id,
        forumId: forumId,
        userId: userId,
        content: content,
        isAcceptedAnswer: isAcceptedAnswer,
        isCommunityFavorite: isCommunityFavorite,
        upvotesCount: upvotesCount,
        downvotesCount: downvotesCount,
        netVotes: netVotes,
        hasUserVoted: hasUserVoted,
        userVoteType: userVoteType,
        isAutoHidden: isAutoHidden,
        isFlagged: isFlagged,
        createdAt: createdAt,
        updatedAt: updatedAt,
        user: user?.toEntity(),
      );

  @override
  List<Object?> get props => [
        id, forumId, userId, content,
        isAcceptedAnswer, isCommunityFavorite,
        upvotesCount, downvotesCount, netVotes,
        hasUserVoted, userVoteType,
        isAutoHidden, isFlagged,
        createdAt, updatedAt, user,
      ];
}

