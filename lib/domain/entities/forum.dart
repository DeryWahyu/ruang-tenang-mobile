import 'package:equatable/equatable.dart';

class ForumCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final DateTime createdAt;

  const ForumCategory({
    required this.id,
    required this.name,
    this.slug = '',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, slug, createdAt];
}

class ForumPostSortOptions extends Equatable {
  final String top;
  final String newest;
  final String oldest;

  const ForumPostSortOptions({
    this.top = 'top',
    this.newest = 'newest',
    this.oldest = 'oldest',
  });

  @override
  List<Object?> get props => [top, newest, oldest];
}

class UserBrief extends Equatable {
  final int id;
  final String name;
  final String avatar;
  final int exp;

  const UserBrief({
    required this.id,
    required this.name,
    this.avatar = '',
    this.exp = 0,
  });

  @override
  List<Object?> get props => [id, name, avatar, exp];
}

class ForumThread extends Equatable {
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
  final UserBrief? user;
  final ForumCategory? category;
  final String createdAt;
  final String updatedAt;

  const ForumThread({
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

  ForumThread copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? slug,
    String? title,
    String? content,
    bool? isFlagged,
    bool? hasAcceptedAnswer,
    int? repliesCount,
    int? likesCount,
    bool? isLiked,
    UserBrief? user,
    ForumCategory? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return ForumThread(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      content: content ?? this.content,
      isFlagged: isFlagged ?? this.isFlagged,
      hasAcceptedAnswer: hasAcceptedAnswer ?? this.hasAcceptedAnswer,
      repliesCount: repliesCount ?? this.repliesCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      user: user ?? this.user,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, categoryId, slug, title, content,
        isFlagged, hasAcceptedAnswer, repliesCount, likesCount, isLiked,
        user, category, createdAt, updatedAt,
      ];
}

class ForumPost extends Equatable {
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
  final UserBrief? user;

  const ForumPost({
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