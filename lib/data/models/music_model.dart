import '../../domain/entities/music.dart';

class SongCategoryModel extends SongCategory {
  const SongCategoryModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.thumbnail,
    super.songCount,
    super.createdAt,
  });

  factory SongCategoryModel.fromJson(Map<String, dynamic> json) {
    return SongCategoryModel(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      songCount: (json['song_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'thumbnail': thumbnail,
    'song_count': songCount,
  };
}

class SongModel extends Song {
  const SongModel({
    required super.id,
    super.slug,
    required super.title,
    required super.filePath,
    required super.thumbnail,
    required super.categoryId,
    super.category,
    super.createdAt,
    super.updatedAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String?,
      title: json['title'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      category: json['category'] != null
          ? SongCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  Song toEntity() => Song(
    id: id,
    slug: slug,
    title: title,
    filePath: filePath,
    thumbnail: thumbnail,
    categoryId: categoryId,
    category: category,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'title': title,
    'file_path': filePath,
    'thumbnail': thumbnail,
    'category_id': categoryId,
  };
}

class PlaylistItemModel extends PlaylistItem {
  const PlaylistItemModel({
    required super.id,
    super.uuid,
    required super.playlistId,
    required super.songId,
    required super.position,
    super.addedAt,
    super.song,
  });

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistItemModel(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String?,
      playlistId: (json['playlist_id'] as num?)?.toInt() ?? 0,
      songId: (json['song_id'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      addedAt: json['added_at'] != null 
          ? DateTime.tryParse(json['added_at'].toString()) 
          : null,
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
    song: song,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'playlist_id': playlistId,
    'song_id': songId,
    'position': position,
  };
}

class PlaylistUserModel extends PlaylistUser {
  const PlaylistUserModel({
    required super.id,
    required super.name,
    super.avatar,
  });

  factory PlaylistUserModel.fromJson(Map<String, dynamic> json) {
    return PlaylistUserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  PlaylistUser toEntity() => PlaylistUser(
    id: id,
    name: name,
    avatar: avatar,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
  };
}

class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.uuid,
    super.slug,
    super.userId,
    required super.name,
    super.description,
    super.thumbnail,
    super.isPublic,
    super.isAdminPlaylist,
    super.itemCount,
    super.totalSongs,
    super.createdAt,
    super.updatedAt,
    super.user,
    super.items,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String? ?? '',
      slug: json['slug'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isAdminPlaylist: json['is_admin_playlist'] as bool? ?? false,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      totalSongs: (json['total_songs'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
      user: json['user'] != null
          ? PlaylistUserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((e) => PlaylistItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  Playlist toEntity() => Playlist(
    id: id,
    uuid: uuid,
    slug: slug,
    userId: userId,
    name: name,
    description: description,
    thumbnail: thumbnail,
    isPublic: isPublic,
    isAdminPlaylist: isAdminPlaylist,
    itemCount: itemCount,
    totalSongs: totalSongs,
    createdAt: createdAt,
    updatedAt: updatedAt,
    user: user,
    items: items,
  );
}

class PlaylistListItemModel extends PlaylistListItem {
  const PlaylistListItemModel({
    required super.id,
    super.uuid,
    super.slug,
    required super.name,
    super.description,
    super.thumbnail,
    super.isPublic,
    super.isAdminPlaylist,
    super.itemCount,
    super.createdAt,
    super.updatedAt,
    super.user,
  });

  factory PlaylistListItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistListItemModel(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String?,
      slug: json['slug'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isAdminPlaylist: json['is_admin_playlist'] as bool? ?? false,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
      user: json['user'] != null
          ? PlaylistUserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  PlaylistListItem toEntity() => PlaylistListItem(
    id: id,
    uuid: uuid,
    slug: slug,
    name: name,
    description: description,
    thumbnail: thumbnail,
    isPublic: isPublic,
    isAdminPlaylist: isAdminPlaylist,
    itemCount: itemCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    user: user,
  );
}