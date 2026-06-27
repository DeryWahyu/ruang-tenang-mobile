import 'package:equatable/equatable.dart';

class ArticleCategory extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String description;
  final DateTime createdAt;

  const ArticleCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, slug, name, description, createdAt];
}

class ArticleAuthor extends Equatable {
  final int id;
  final String name;

  const ArticleAuthor({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class Article extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String thumbnail;
  final String content;
  final int categoryId;
  final ArticleCategory? category;
  final int? userId;
  final ArticleAuthor? author;
  final String status;
  final String moderationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
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

class ArticleListItem extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String thumbnail;
  final String excerpt;
  final int categoryId;
  final ArticleCategory? category;
  final int? userId;
  final ArticleAuthor? author;
  final String status;
  final String moderationStatus;
  final DateTime createdAt;

  const ArticleListItem({
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
