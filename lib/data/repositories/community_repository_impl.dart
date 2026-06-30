import '../../domain/entities/community.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/remote/community_remote_datasource.dart';

/// Implementasi [CommunityRepository]. Memetakan model dari remote
/// data source ke entity di batas data-layer.
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource _remote;

  CommunityRepositoryImpl({required CommunityRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<CommunityStats> getStats() async {
    final model = await _remote.getStats();
    return model.toEntity();
  }
}
