import '../entities/music.dart';

abstract class MusicRepository {
  Future<List<SongCategory>> getSongCategories();
  Future<List<Song>> getSongsByCategory(String slug);
  Future<List<PlaylistListItem>> getMyPlaylists();
  Future<List<PlaylistListItem>> getPublicPlaylists();
  Future<Playlist> getPlaylist(String uuid);
  Future<Playlist> createPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required bool isPublic,
  });
}
