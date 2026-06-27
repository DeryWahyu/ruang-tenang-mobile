import 'package:equatable/equatable.dart';

class SongCategory extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String thumbnail;
  final int songCount;
  final DateTime createdAt;

  const SongCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.thumbnail,
    this.songCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, slug, name, thumbnail, songCount, createdAt];
}

class Song extends Equatable {
  final int id;
  final String slug;
  final String title;
  final String filePath;
  final String thumbnail;
  final int categoryId;
  final SongCategory? category;
  final DateTime createdAt;

  const Song({
    required this.id,
    required this.slug,
    required this.title,
    required this.filePath,
    required this.thumbnail,
    required this.categoryId,
    this.category,
    required this.createdAt,
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
      ];
}

class PlaylistItem extends Equatable {
  final int id;
  final String uuid;
  final int playlistId;
  final int songId;
  final int position;
  final DateTime addedAt;
  final Song? song;

  const PlaylistItem({
    required this.id,
    required this.uuid,
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedAt,
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
  final int userId;
  final String name;
  final String description;
  final String thumbnail;
  final bool isPublic;
  final int itemCount;
  final int totalSongs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlaylistItem> items;

  const Playlist({
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

class PlaylistListItem extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final String description;
  final String thumbnail;
  final bool isPublic;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistListItem({
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
