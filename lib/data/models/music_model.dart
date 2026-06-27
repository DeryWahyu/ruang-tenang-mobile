import 'package:equatable/equatable.dart';
import '../../domain/entities/music.dart';

class SongCategoryModel extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String thumbnail;
  final int songCount;
  final DateTime createdAt;

  const SongCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.thumbnail,
    this.songCount = 0,
    required this.createdAt,
  });

  factory SongCategoryModel.fromJson(Map<String, dynamic> json) {
    return SongCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      songCount: (json['song_count'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  SongCategory toEntity() => SongCategory(
        id: id,
        slug: slug,
        name: name,
        thumbnail: thumbnail,
        songCount: songCount,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, slug, name, thumbnail, songCount, createdAt];
}

class SongModel extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String filePath;
  final String thumbnail;
  final int categoryId;
  final SongCategoryModel? category;
  final DateTime createdAt;

  const SongModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.filePath,
    required this.thumbnail,
    required this.categoryId,
    this.category,
    required this.createdAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      category: json['category'] != null
          ? SongCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  Song toEntity() => Song(
        id: id,
        slug: slug,
        title: title,
        filePath: filePath,
        thumbnail: thumbnail,
        categoryId: categoryId,
        category: category?.toEntity(),
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        filePath,
        thumbnail,
        categoryId,
        category,
        createdAt,
      ];
}

class PlaylistItemModel extends Equatable {
  final int id;
  final String uuid;
  final int playlistId;
  final int songId;
  final int position;
  final DateTime addedAt;
  final SongModel? song;

  const PlaylistItemModel({
    required this.id,
    required this.uuid,
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedAt,
    this.song,
  });

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      playlistId: (json['playlist_id'] as num?)?.toInt() ?? 0,
      songId: (json['song_id'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      addedAt: _parseDate(json['added_at']) ?? DateTime.now(),
      song: json['song'] != null
          ? SongModel.fromJson(Map<String, dynamic>.from(json['song'] as Map))
          : null,
    );
  }

  PlaylistItem toEntity() => PlaylistItem(
        id: id,
        uuid: uuid,
        playlistId: playlistId,
        songId: songId,
        position: position,
        addedAt: addedAt,
        song: song?.toEntity(),
      );

  @override
  List<Object?> get props => [
        id,
        uuid,
        playlistId,
        songId,
        position,
        addedAt,
        song,
      ];
}

class PlaylistModel extends Equatable {
  final int id;
  final String uuid;
  final int userId;
  final String name;
  final String description;
  final String thumbnail;
  final bool isPublic;
  final int itemCount;
  final int totalSongs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlaylistItemModel> items;

  const PlaylistModel({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.name,
    required this.description,
    required this.thumbnail,
    this.isPublic = false,
    this.itemCount = 0,
    this.totalSongs = 0,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      totalSongs: (json['total_songs'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PlaylistItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Playlist toEntity() => Playlist(
        id: id,
        uuid: uuid,
        userId: userId,
        name: name,
        description: description,
        thumbnail: thumbnail,
        isPublic: isPublic,
        itemCount: itemCount,
        totalSongs: totalSongs,
        createdAt: createdAt,
        updatedAt: updatedAt,
        items: items.map((e) => e.toEntity()).toList(),
      );

  @override
  List<Object?> get props => [
        id,
        uuid,
        userId,
        name,
        description,
        thumbnail,
        isPublic,
        itemCount,
        totalSongs,
        createdAt,
        updatedAt,
        items,
      ];
}

class PlaylistListItemModel extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final String description;
  final String thumbnail;
  final bool isPublic;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistListItemModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.description,
    required this.thumbnail,
    this.isPublic = false,
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaylistListItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistListItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  PlaylistListItem toEntity() => PlaylistListItem(
        id: id,
        uuid: uuid,
        name: name,
        description: description,
        thumbnail: thumbnail,
        isPublic: isPublic,
        itemCount: itemCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        description,
        thumbnail,
        isPublic,
        itemCount,
        createdAt,
        updatedAt,
      ];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}
