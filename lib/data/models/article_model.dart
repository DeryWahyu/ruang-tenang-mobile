import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
import '../../domain/entities/article.dart';

class ArticleCategoryModel extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String description;
  final DateTime createdAt;

  const ArticleCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  factory ArticleCategoryModel.fromJson(Map<String, dynamic> json) {
    return ArticleCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
    );
  }

  ArticleCategory toEntity() => ArticleCategory(
        id: id,
        slug: slug,
        name: name,
        description: description,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, slug, name, description, createdAt];
}

class ArticleAuthorModel extends Equatable {
  final int id;
  final String name;

  const ArticleAuthorModel({
    required this.id,
    required this.name,
  });

  factory ArticleAuthorModel.fromJson(Map<String, dynamic> json) {
    return ArticleAuthorModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  ArticleAuthor toEntity() => ArticleAuthor(
        id: id,
        name: name,
      );

  @override
  List<Object?> get props => [id, name];
}

class ArticleModel extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String thumbnail;
  final String content;
  final int categoryId;
  final ArticleCategoryModel? category;
  final int? userId;
  final ArticleAuthorModel? author;
  final String status;
  final String moderationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleModel({
    required this.id,
    required this.slug,
    required this.title,
    this.thumbnail = '',
    required this.content,
    required this.categoryId,
    this.category,
    this.userId,
    this.author,
    required this.status,
    this.moderationStatus = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      content: json['content'] as String? ?? '',
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      category: json['category'] != null
          ? ArticleCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      userId: (json['user_id'] as num?)?.toInt(),
      author: json['author'] != null
          ? ArticleAuthorModel.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : null,
      status: json['status'] as String? ?? '',
      moderationStatus: json['moderation_status'] as String? ?? '',
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
      updatedAt: Json.date(json['updated_at']) ?? DateTime.now(),
    );
  }

  Article toEntity() => Article(
        id: id,
        slug: slug,
        title: title,
        thumbnail: thumbnail,
        content: content,
        categoryId: categoryId,
        category: category?.toEntity(),
        userId: userId,
        author: author?.toEntity(),
        status: status,
        moderationStatus: moderationStatus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        thumbnail,
        content,
        categoryId,
        category,
        userId,
        author,
        status,
        moderationStatus,
        createdAt,
        updatedAt,
      ];
}

class ArticleListItemModel extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String thumbnail;
  final String excerpt;
  final int categoryId;
  final ArticleCategoryModel? category;
  final int? userId;
  final ArticleAuthorModel? author;
  final String status;
  final String moderationStatus;
  final DateTime createdAt;

  const ArticleListItemModel({
    required this.id,
    required this.slug,
    required this.title,
    this.thumbnail = '',
    required this.excerpt,
    required this.categoryId,
    this.category,
    this.userId,
    this.author,
    required this.status,
    this.moderationStatus = '',
    required this.createdAt,
  });

  factory ArticleListItemModel.fromJson(Map<String, dynamic> json) {
    return ArticleListItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      category: json['category'] != null
          ? ArticleCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      userId: (json['user_id'] as num?)?.toInt(),
      author: json['author'] != null
          ? ArticleAuthorModel.fromJson(Map<String, dynamic>.from(json['author'] as Map))
          : null,
      status: json['status'] as String? ?? '',
      moderationStatus: json['moderation_status'] as String? ?? '',
      createdAt: Json.date(json['created_at']) ?? DateTime.now(),
    );
  }

  ArticleListItem toEntity() => ArticleListItem(
        id: id,
        slug: slug,
        title: title,
        thumbnail: thumbnail,
        excerpt: excerpt,
        categoryId: categoryId,
        category: category?.toEntity(),
        userId: userId,
        author: author?.toEntity(),
        status: status,
        moderationStatus: moderationStatus,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        thumbnail,
        excerpt,
        categoryId,
        category,
        userId,
        author,
        status,
        moderationStatus,
        createdAt,
      ];
}

