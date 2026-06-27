import '../../domain/entities/search.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/remote/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;

  SearchRepositoryImpl({required SearchRemoteDataSource remote}) : _remote = remote;

  @override
  Future<SearchResult> searchGlobal(String query) async {
    final model = await _remote.searchGlobal(query);
    return model.toEntity();
  }
}