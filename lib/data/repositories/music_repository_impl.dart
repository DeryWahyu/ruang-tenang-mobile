import '../../domain/entities/music.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/remote/music_remote_datasource.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource _remote;

  MusicRepositoryImpl({required MusicRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Playlist> updatePlaylist(
    String uuid, {
    required String name,
    required String description,
    required String thumbnail,
    required bool isPublic,
  }) async => (await _remote.updatePlaylist(
    uuid,
    name: name,
    description: description,
    thumbnail: thumbnail,
    isPublic: isPublic,
  )).toEntity();

  @override
  Future<void> deletePlaylist(String uuid) => _remote.deletePlaylist(uuid);

  @override
  Future<void> addSong(String uuid, int songId) =>
      _remote.addSong(uuid, songId);

  @override
  Future<void> removeSong(String uuid, int songId) =>
      _remote.removeSong(uuid, songId);

  @override
  Future<List<SongCategory>> getSongCategories() async {
    final models = await _remote.getSongCategories();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Song>> getSongsByCategory(String slug) async {
    final models = await _remote.getSongsByCategory(slug);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<PlaylistListItem>> getMyPlaylists() async {
    final models = await _remote.getMyPlaylists();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<PlaylistListItem>> getPublicPlaylists() async {
    final models = await _remote.getPublicPlaylists();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Playlist> getPlaylist(String uuid) async {
    final model = await _remote.getPlaylist(uuid);
    return model.toEntity();
  }

  @override
  Future<Playlist> createPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required bool isPublic,
  }) async {
    final model = await _remote.createPlaylist(
      name: name,
      description: description,
      thumbnail: thumbnail,
      isPublic: isPublic,
    );
    return model.toEntity();
  }
}
