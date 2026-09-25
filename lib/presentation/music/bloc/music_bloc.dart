import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/utils/error_message.dart';
import '../../../core/utils/media_url.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/usecases/music/music_usecases.dart';
import '../../../domain/entities/music.dart';
import 'music_event.dart';
import 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final GetSongCategoriesUseCase _getCategories;
  final GetSongsByCategoryUseCase _getSongsByCategory;
  final GetPublicPlaylistsUseCase _getPublicPlaylists;
  final GetMyPlaylistsUseCase _getMyPlaylists;
  final CreatePlaylistUseCase _createPlaylist;
  final UploadRepository _uploadRepository;
  final AudioPlayer _audioPlayer;
  bool _handledCompletionForCurrentTrack = false;

  MusicBloc({
    required GetSongCategoriesUseCase getCategories,
    required GetSongsByCategoryUseCase getSongsByCategory,
    required GetPublicPlaylistsUseCase getPublicPlaylists,
    required GetMyPlaylistsUseCase getMyPlaylists,
    required CreatePlaylistUseCase createPlaylist,
    required UploadRepository uploadRepository,
  }) : _getCategories = getCategories,
       _getSongsByCategory = getSongsByCategory,
       _getPublicPlaylists = getPublicPlaylists,
       _getMyPlaylists = getMyPlaylists,
       _createPlaylist = createPlaylist,
       _uploadRepository = uploadRepository,
       _audioPlayer = AudioPlayer(),
       super(const MusicState()) {
    on<MusicFetchInitialDataRequested>(_onFetchInitialData);
    on<MusicCategorySelected>(_onCategorySelected);
    on<MusicPlaySongRequested>(_onPlaySongRequested);
    on<MusicPlayQueueRequested>(_onPlayQueueRequested);
    on<MusicQueueAdvanceRequested>(_onQueueAdvanceRequested);
    on<MusicCreatePlaylistRequested>(_onCreatePlaylistRequested);
    on<MusicPauseSongRequested>(_onPauseSongRequested);
    on<MusicResumeSongRequested>(_onResumeSongRequested);
    on<MusicStopSongRequested>(_onStopSongRequested);
    on<MusicPlaybackStateChanged>(_onPlaybackStateChanged);
    on<MusicPlaybackFailed>(_onPlaybackFailed);

    // Listen to audio player state
    _audioPlayer.positionStream.listen((pos) {
      if (!isClosed) {
        add(
          MusicPlaybackStateChanged(
            isPlaying: _audioPlayer.playing,
            isBuffering:
                _audioPlayer.processingState == ProcessingState.loading ||
                _audioPlayer.processingState == ProcessingState.buffering,
            position: pos,
            duration: _audioPlayer.duration ?? Duration.zero,
          ),
        );
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (!isClosed) {
        add(
          MusicPlaybackStateChanged(
            isPlaying: state.playing,
            isBuffering:
                state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering,
            position: _audioPlayer.position,
            duration: _audioPlayer.duration ?? Duration.zero,
          ),
        );

        // Move to the next queued track, or clear the player at queue end.
        if (state.processingState == ProcessingState.completed &&
            !_handledCompletionForCurrentTrack) {
          _handledCompletionForCurrentTrack = true;
          if (this.state.queueIndex + 1 < this.state.playbackQueue.length) {
            add(const MusicQueueAdvanceRequested());
          } else {
            add(const MusicStopSongRequested());
          }
        }
      }
    });

    _audioPlayer.errorStream.listen((error) {
      if (kDebugMode) debugPrint('Music: error stream audio: $error');
      if (!isClosed && state.currentPlayingSong != null) {
        add(
          const MusicPlaybackFailed(
            'Lagu belum dapat diputar. Periksa koneksi, lalu coba lagi.',
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

  Future<void> _onFetchInitialData(
    MusicFetchInitialDataRequested event,
    Emitter<MusicState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MusicStatus.loading,
        clearErrorMessage: true,
        clearPlaybackError: true,
      ),
    );

    List<SongCategory> categories = [];
    List<PlaylistListItem> publicPlaylists = [];
    List<PlaylistListItem> myPlaylists = [];
    String? errorMsg;

    // Categories are the primary content; failure here is treated as fatal.
    try {
      categories = await _getCategories();
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal memuat kategori: $e');
      errorMsg = ErrorMessage.from(e, 'Gagal memuat kategori musik');
    }

    // Public & personal playlists are supplementary; failures are non-fatal.
    try {
      publicPlaylists = await _getPublicPlaylists();
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal memuat playlist publik: $e');
    }

    try {
      myPlaylists = await _getMyPlaylists();
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal memuat playlist saya: $e');
    }

    // If the primary content failed and we have nothing to show, surface the error.
    if (errorMsg != null && categories.isEmpty) {
      emit(state.copyWith(status: MusicStatus.failure, errorMessage: errorMsg));
      return;
    }

    emit(
      state.copyWith(
        status: MusicStatus.success,
        categories: categories,
        publicPlaylists: publicPlaylists,
        myPlaylists: myPlaylists,
        clearErrorMessage: true,
      ),
    );

    if (categories.isNotEmpty) {
      add(MusicCategorySelected(categories.first.slug ?? ""));
    }
  }

  Future<void> _onCategorySelected(
    MusicCategorySelected event,
    Emitter<MusicState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          selectedCategorySlug: event.slug,
          currentCategorySongs: const [],
          isLoadingCategorySongs: true,
          clearCategoryError: true,
        ),
      );
      final songs = await _getSongsByCategory(event.slug);
      if (state.selectedCategorySlug != event.slug) return;
      emit(
        state.copyWith(
          currentCategorySongs: songs,
          isLoadingCategorySongs: false,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal memuat lagu kategori: $e');
      if (state.selectedCategorySlug != event.slug) return;
      emit(
        state.copyWith(
          isLoadingCategorySongs: false,
          categoryErrorMessage: ErrorMessage.from(
            e,
            'Lagu dalam kategori ini belum berhasil dimuat.',
          ),
        ),
      );
    }
  }

  Future<void> _onPlaySongRequested(
    MusicPlaySongRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _startSong(
      event.song,
      queue: [event.song],
      queueIndex: 0,
      emit: emit,
    );
  }

  Future<void> _onPlayQueueRequested(
    MusicPlayQueueRequested event,
    Emitter<MusicState> emit,
  ) async {
    if (event.songs.isEmpty) return;
    final startIndex = event.startIndex
        .clamp(0, event.songs.length - 1)
        .toInt();
    await _startSong(
      event.songs[startIndex],
      queue: List<Song>.unmodifiable(event.songs),
      queueIndex: startIndex,
      emit: emit,
    );
  }

  Future<void> _onQueueAdvanceRequested(
    MusicQueueAdvanceRequested event,
    Emitter<MusicState> emit,
  ) async {
    final nextIndex = state.queueIndex + 1;
    if (nextIndex >= state.playbackQueue.length) {
      add(const MusicStopSongRequested());
      return;
    }
    await _startSong(
      state.playbackQueue[nextIndex],
      queue: state.playbackQueue,
      queueIndex: nextIndex,
      emit: emit,
    );
  }

  Future<void> _startSong(
    Song song, {
    required List<Song> queue,
    required int queueIndex,
    required Emitter<MusicState> emit,
  }) async {
    emit(state.copyWith(clearPlaybackError: true));
    // Audio may use a signed URL, so do not append an image cache-buster.
    final url = resolveMediaUrl(song.filePath);
    if (url == null) {
      await _audioPlayer.stop();
      emit(
        state.copyWith(
          clearPlayingSong: true,
          playbackQueue: const [],
          queueIndex: 0,
          isPlaying: false,
          isBuffering: false,
          position: Duration.zero,
          duration: Duration.zero,
          playbackErrorMessage: 'Audio lagu ini belum tersedia.',
        ),
      );
      return;
    }

    // Ignore a stale completion from the previous source while setUrl changes
    // the player's item; re-arm this once the new source is ready.
    _handledCompletionForCurrentTrack = true;
    emit(
      state.copyWith(
        currentPlayingSong: song,
        playbackQueue: queue,
        queueIndex: queueIndex,
        isPlaying: false,
        isBuffering: true,
        position: Duration.zero,
        duration: Duration.zero,
        clearPlaybackError: true,
      ),
    );

    try {
      await _audioPlayer.setUrl(url);
      _handledCompletionForCurrentTrack = false;
      unawaited(
        _audioPlayer.play().catchError((Object error) {
          if (kDebugMode) debugPrint('Music: gagal memulai audio: $error');
          if (!isClosed) {
            add(
              const MusicPlaybackFailed(
                'Lagu belum dapat diputar. Periksa koneksi, lalu coba lagi.',
              ),
            );
          }
        }),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal menyiapkan audio: $e');
      await _audioPlayer.stop();
      emit(
        state.copyWith(
          clearPlayingSong: true,
          playbackQueue: const [],
          queueIndex: 0,
          isPlaying: false,
          isBuffering: false,
          playbackErrorMessage:
              'Lagu belum dapat diputar. Periksa koneksi, lalu coba lagi.',
        ),
      );
    }
  }

  Future<void> _onPauseSongRequested(
    MusicPauseSongRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioPlayer.pause();
  }

  Future<void> _onResumeSongRequested(
    MusicResumeSongRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioPlayer.play();
  }

  Future<void> _onCreatePlaylistRequested(
    MusicCreatePlaylistRequested event,
    Emitter<MusicState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true, clearPlaybackError: true));
    try {
      String thumbnailUrl = '';
      if (event.thumbnailFile != null) {
        thumbnailUrl = await _uploadRepository.uploadImage(
          event.thumbnailFile!,
        );
      }

      await _createPlaylist(
        name: event.name,
        description: event.description,
        thumbnail: thumbnailUrl,
        isPublic: event.isPublic,
      );

      // Refresh my playlists
      final myPlaylists = await _getMyPlaylists();
      emit(state.copyWith(myPlaylists: myPlaylists, clearErrorMessage: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal membuat playlist: $e');
      emit(
        state.copyWith(
          errorMessage: ErrorMessage.from(e, 'Gagal membuat playlist'),
        ),
      );
    }
  }

  Future<void> _onStopSongRequested(
    MusicStopSongRequested event,
    Emitter<MusicState> emit,
  ) async {
    _handledCompletionForCurrentTrack = true;
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        clearPlayingSong: true,
        playbackQueue: const [],
        queueIndex: 0,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );
  }

  void _onPlaybackStateChanged(
    MusicPlaybackStateChanged event,
    Emitter<MusicState> emit,
  ) {
    emit(
      state.copyWith(
        isPlaying: event.isPlaying,
        isBuffering: event.isBuffering,
        position: event.position,
        duration: event.duration,
      ),
    );
  }

  void _onPlaybackFailed(MusicPlaybackFailed event, Emitter<MusicState> emit) {
    if (state.currentPlayingSong == null) return;
    emit(
      state.copyWith(
        clearPlayingSong: true,
        playbackQueue: const [],
        queueIndex: 0,
        isPlaying: false,
        isBuffering: false,
        playbackErrorMessage: event.message,
      ),
    );
  }
}
