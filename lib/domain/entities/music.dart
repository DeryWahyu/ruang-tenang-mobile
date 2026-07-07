import 'package:equatable/equatable.dart';

class PlaylistUser extends Equatable {
  final int id;
  final String name;
  final String? avatar;

  const PlaylistUser({
    required this.id,
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, name, avatar];
}

class SongCategory extends Equatable {
  final int id;
  final String? slug;
  final String name;
  final String thumbnail;
  final int songCount;
  final DateTime? createdAt;

  const SongCategory({
    required this.id,
    this.slug,
    required this.name,
    required this.thumbnail,
    this.songCount = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, slug, name, thumbnail, songCount, createdAt];
}

class Song extends Equatable {
  final int id;
  final String? slug;
  final String title;
  final String? filePath;
  final String thumbnail;
  final int categoryId;
  final SongCategory? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Song({
    required this.id,
    this.slug,
    required this.title,
    this.filePath,
    required this.thumbnail,
    required this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

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
        updatedAt,
      ];
}

class PlaylistItem extends Equatable {
  final int id;
  final String? uuid;
  final int playlistId;
  final int songId;
  final int position;
  final DateTime? addedAt;
  final Song? song;

  const PlaylistItem({
    required this.id,
    this.uuid,
    required this.playlistId,
    required this.songId,
    required this.position,
    this.addedAt,
    this.song,
  });

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

class Playlist extends Equatable {
  final int id;
  final String uuid;
  final String? slug;
  final int? userId;
  final String name;
  final String? description;
  final String? thumbnail;
  final bool isPublic;
  final bool isAdminPlaylist;
  final int itemCount;
  final int totalSongs;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlaylistUser? user;
  final List<PlaylistItem> items;

  const Playlist({
    required this.id,
    required this.uuid,
    this.slug,
    this.userId,
    required this.name,
    this.description,
    this.thumbnail,
    this.isPublic = false,
    this.isAdminPlaylist = false,
    this.itemCount = 0,
    this.totalSongs = 0,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        slug,
        userId,
        name,
        description,
        thumbnail,
        isPublic,
        isAdminPlaylist,
        itemCount,
        totalSongs,
        createdAt,
        updatedAt,
        user,
        items,
      ];
}

class PlaylistListItem extends Equatable {
  final int id;
  final String? uuid;
  final String? slug;
  final String name;
  final String? description;
  final String? thumbnail;
  final bool isPublic;
  final bool isAdminPlaylist;
  final int itemCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlaylistUser? user;

  const PlaylistListItem({
    required this.id,
    this.uuid,
    this.slug,
    required this.name,
    this.description,
    this.thumbnail,
    this.isPublic = false,
    this.isAdminPlaylist = false,
    this.itemCount = 0,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        slug,
        name,
        description,
        thumbnail,
        isPublic,
        isAdminPlaylist,
        itemCount,
        createdAt,
        updatedAt,
        user,
      ];
}