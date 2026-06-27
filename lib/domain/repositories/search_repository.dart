import '../entities/search.dart';

abstract class SearchRepository {
  Future<SearchResult> searchGlobal(String query);
}