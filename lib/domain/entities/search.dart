import 'package:equatable/equatable.dart';
import 'article.dart';
import 'music.dart';

class SearchResult extends Equatable {
  final List<ArticleListItem> articles;
  final List<Song> songs;
  final int total;

  const SearchResult({
    this.articles = const [],
    this.songs = const [],
    this.total = 0,
  });

  @override
  List<Object?> get props => [articles, songs, total];
}