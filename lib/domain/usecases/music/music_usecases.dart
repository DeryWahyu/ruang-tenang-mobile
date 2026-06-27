import '../../entities/music.dart';
import '../../repositories/music_repository.dart';

class GetSongCategoriesUseCase {
  final MusicRepository repository;
  GetSongCategoriesUseCase(this.repository);

  Future<List<SongCategory>> call() => repository.getSongCategories();
}

class GetSongsByCategoryUseCase {
  final MusicRepository repository;
  GetSongsByCategoryUseCase(this.repository);

  Future<List<Song>> call(String slug) => repository.getSongsByCategory(slug);
}

class GetPublicPlaylistsUseCase {
  final MusicRepository repository;
  GetPublicPlaylistsUseCase(this.repository);

  Future<List<PlaylistListItem>> call() => repository.getPublicPlaylists();
}

class GetMyPlaylistsUseCase {
  final MusicRepository repository;
  GetMyPlaylistsUseCase(this.repository);

  Future<List<PlaylistListItem>> call() => repository.getMyPlaylists();
}

class GetPlaylistUseCase {
  final MusicRepository repository;
  GetPlaylistUseCase(this.repository);

  Future<Playlist> call(String uuid) => repository.getPlaylist(uuid);
}

class CreatePlaylistUseCase {
  final MusicRepository repository;
  CreatePlaylistUseCase(this.repository);

  Future<Playlist> call({
    required String name,
    required String description,
    required String thumbnail,
    required bool isPublic,
  }) {
    return repository.createPlaylist(
      name: name,
      description: description,
      thumbnail: thumbnail,
      isPublic: isPublic,
    );
  }
}
