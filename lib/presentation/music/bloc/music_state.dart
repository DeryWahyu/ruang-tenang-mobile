import 'package:equatable/equatable.dart';
import '../../../domain/entities/music.dart';

enum MusicStatus { initial, loading, success, failure }

class MusicState extends Equatable {
  final MusicStatus status;
  final List<SongCategory> categories;
  final List<PlaylistListItem> publicPlaylists;
  final List<PlaylistListItem> myPlaylists;
  final List<Song> currentCategorySongs;
  final String? errorMessage;
  final Song? currentPlayingSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const MusicState({
    this.status = MusicStatus.initial,
    this.categories = const [],
    this.publicPlaylists = const [],
    this.myPlaylists = const [],
    this.currentCategorySongs = const [],
    this.errorMessage,
    this.currentPlayingSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicState copyWith({
    MusicStatus? status,
    List<SongCategory>? categories,
    List<PlaylistListItem>? publicPlaylists,
    List<PlaylistListItem>? myPlaylists,
    List<Song>? currentCategorySongs,
    String? errorMessage,
    Song? currentPlayingSong,
    bool clearPlayingSong = false,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return MusicState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      publicPlaylists: publicPlaylists ?? this.publicPlaylists,
      myPlaylists: myPlaylists ?? this.myPlaylists,
      currentCategorySongs: currentCategorySongs ?? this.currentCategorySongs,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPlayingSong: clearPlayingSong ? null : (currentPlayingSong ?? this.currentPlayingSong),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        publicPlaylists,
        myPlaylists,
        currentCategorySongs,
        errorMessage,
        currentPlayingSong,
        isPlaying,
        position,
        duration,
      ];
}
