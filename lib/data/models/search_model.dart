import 'package:equatable/equatable.dart';
import '../../domain/entities/search.dart';
import 'article_model.dart';
import 'music_model.dart';

class SearchResultModel extends Equatable {
  final List<ArticleListItemModel> articles;
  final List<SongModel> songs;
  final int total;

  const SearchResultModel({
    this.articles = const [],
    this.songs = const [],
    this.total = 0,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) => ArticleListItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => SongModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  SearchResult toEntity() => SearchResult(
        articles: articles.map((e) => e.toEntity()).toList(),
        songs: songs.map((e) => e.toEntity()).toList(),
        total: total,
      );

  @override
  List<Object?> get props => [articles, songs, total];
}