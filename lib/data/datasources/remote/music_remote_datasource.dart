import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/music_model.dart';

class MusicRemoteDataSource {
  final ApiClient _apiClient;

  MusicRemoteDataSource(this._apiClient);

  /// GET /song-categories
  Future<List<SongCategoryModel>> getSongCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.songCategories,
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat kategori lagu');
    }

    return response.data!
        .map((e) => SongCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /song-categories/:slug/songs
  Future<List<SongModel>> getSongsByCategory(String slug) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.songCategories}/$slug/songs',
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat lagu');
    }

    return response.data!
        .map((e) => SongModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /songs/:id
  Future<SongModel> getSong(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.songs}/$id',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat detail lagu');
    }

    return SongModel.fromJson(response.data!);
  }

  /// GET /playlists
  Future<List<PlaylistListItemModel>> getMyPlaylists() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.playlists,
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat playlist');
    }

    return response.data!
        .map((e) => PlaylistListItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /playlists/public
  Future<List<PlaylistListItemModel>> getPublicPlaylists() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.playlists}/public',
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat playlist publik');
    }

    return response.data!
        .map((e) => PlaylistListItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /playlists/:uuid
  Future<PlaylistModel> getPlaylist(String uuid) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.playlists}/$uuid',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat detail playlist');
    }

    return PlaylistModel.fromJson(response.data!);
  }

  /// POST /playlists
  Future<PlaylistModel> createPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required bool isPublic,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.playlists,
      data: {
        'name': name,
        'description': description,
        'thumbnail': thumbnail,
        'is_public': isPublic,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuat playlist');
    }

    return PlaylistModel.fromJson(response.data!);
  }

  /// POST /playlists/:uuid/songs
  Future<void> addSongToPlaylist(String uuid, int songId) async {
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.playlists}/$uuid/songs',
      data: {'song_id': songId},
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal menambahkan lagu ke playlist');
    }
  }
}
