import 'dart:io';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/music.dart';

abstract class MusicEvent extends Equatable {
  const MusicEvent();

  @override
  List<Object?> get props => [];
}

class MusicFetchInitialDataRequested extends MusicEvent {
  const MusicFetchInitialDataRequested();
}

class MusicCategorySelected extends MusicEvent {
  final String slug;
  const MusicCategorySelected(this.slug);

  @override
  List<Object?> get props => [slug];
}

class MusicPlaySongRequested extends MusicEvent {
  final Song song;
  const MusicPlaySongRequested(this.song);

  @override
  List<Object?> get props => [song];
}

class MusicPauseSongRequested extends MusicEvent {
  const MusicPauseSongRequested();
}

class MusicResumeSongRequested extends MusicEvent {
  const MusicResumeSongRequested();
}

class MusicStopSongRequested extends MusicEvent {
  const MusicStopSongRequested();
}

class MusicCreatePlaylistRequested extends MusicEvent {
  final String name;
  final String description;
  final File? thumbnailFile;
  final bool isPublic;

  const MusicCreatePlaylistRequested({
    required this.name,
    required this.description,
    this.thumbnailFile,
    required this.isPublic,
  });

  @override
  List<Object?> get props => [name, description, thumbnailFile, isPublic];
}

class MusicPlaybackStateChanged extends MusicEvent {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const MusicPlaybackStateChanged({
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  @override
  List<Object?> get props => [isPlaying, position, duration];
}
