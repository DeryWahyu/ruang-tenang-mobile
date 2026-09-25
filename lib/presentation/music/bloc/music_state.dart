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
  final String? playbackErrorMessage;
  final Song? currentPlayingSong;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final List<Song> playbackQueue;
  final int queueIndex;
  final String? selectedCategorySlug;
  final bool isLoadingCategorySongs;
  final String? categoryErrorMessage;

  const MusicState({
    this.status = MusicStatus.initial,
    this.categories = const [],
    this.publicPlaylists = const [],
    this.myPlaylists = const [],
    this.currentCategorySongs = const [],
    this.errorMessage,
    this.playbackErrorMessage,
    this.currentPlayingSong,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackQueue = const [],
    this.queueIndex = 0,
    this.selectedCategorySlug,
    this.isLoadingCategorySongs = false,
    this.categoryErrorMessage,
  });

  MusicState copyWith({
    MusicStatus? status,
    List<SongCategory>? categories,
    List<PlaylistListItem>? publicPlaylists,
    List<PlaylistListItem>? myPlaylists,
    List<Song>? currentCategorySongs,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? playbackErrorMessage,
    bool clearPlaybackError = false,
    Song? currentPlayingSong,
    bool clearPlayingSong = false,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    List<Song>? playbackQueue,
    int? queueIndex,
    String? selectedCategorySlug,
    bool clearSelectedCategory = false,
    bool? isLoadingCategorySongs,
    String? categoryErrorMessage,
    bool clearCategoryError = false,
  }) {
    return MusicState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      publicPlaylists: publicPlaylists ?? this.publicPlaylists,
      myPlaylists: myPlaylists ?? this.myPlaylists,
      currentCategorySongs: currentCategorySongs ?? this.currentCategorySongs,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      playbackErrorMessage: clearPlaybackError
          ? null
          : (playbackErrorMessage ?? this.playbackErrorMessage),
      currentPlayingSong: clearPlayingSong
          ? null
          : (currentPlayingSong ?? this.currentPlayingSong),
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackQueue: playbackQueue ?? this.playbackQueue,
      queueIndex: queueIndex ?? this.queueIndex,
      selectedCategorySlug: clearSelectedCategory
          ? null
          : (selectedCategorySlug ?? this.selectedCategorySlug),
      isLoadingCategorySongs:
          isLoadingCategorySongs ?? this.isLoadingCategorySongs,
      categoryErrorMessage: clearCategoryError
          ? null
          : (categoryErrorMessage ?? this.categoryErrorMessage),
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
    playbackErrorMessage,
    currentPlayingSong,
    isPlaying,
    isBuffering,
    position,
    duration,
    playbackQueue,
    queueIndex,
    selectedCategorySlug,
    isLoadingCategorySongs,
    categoryErrorMessage,
  ];
}
