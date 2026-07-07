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
    on<MusicCreatePlaylistRequested>(_onCreatePlaylistRequested);
    on<MusicPauseSongRequested>(_onPauseSongRequested);
    on<MusicResumeSongRequested>(_onResumeSongRequested);
    on<MusicStopSongRequested>(_onStopSongRequested);
    on<MusicPlaybackStateChanged>(_onPlaybackStateChanged);

    // Listen to audio player state
    _audioPlayer.positionStream.listen((pos) {
      if (!isClosed) {
        add(
          MusicPlaybackStateChanged(
            isPlaying: _audioPlayer.playing,
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
            position: _audioPlayer.position,
            duration: _audioPlayer.duration ?? Duration.zero,
          ),
        );

        // Auto-stop when completed
        if (state.processingState == ProcessingState.completed) {
          add(const MusicStopSongRequested());
        }
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
    emit(state.copyWith(status: MusicStatus.loading));

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
      final songs = await _getSongsByCategory(event.slug);
      emit(state.copyWith(currentCategorySongs: songs));
    } catch (e) {
      // Non-fatal: keep previously loaded songs; just log in debug.
      if (kDebugMode) debugPrint('Music: gagal memuat lagu kategori: $e');
    }
  }

  Future<void> _onPlaySongRequested(
    MusicPlaySongRequested event,
    Emitter<MusicState> emit,
  ) async {
    final song = event.song;

    // Resolve a playable absolute URL from the (possibly relative) file path.
    // Use updatedAt as a cache buster so that if the song data is updated, 
    // it will invalidate the cached audio file and download the new one.
    final url = resolveMediaUrl(
      song.filePath, 
      cacheBuster: song.updatedAt?.millisecondsSinceEpoch.toString(),
    );
    
    if (url == null) {
      emit(state.copyWith(errorMessage: 'Lagu tidak memiliki sumber audio yang valid'));
      return;
    }

    emit(state.copyWith(currentPlayingSong: song));

    try {
      // Use LockCachingAudioSource to cache the downloaded audio locally
      // ignore: experimental_member_use
      await _audioPlayer.setAudioSource(LockCachingAudioSource(Uri.parse(url)));
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal memutar audio: $e');
      // Surface the failure and clear the now-unplayable "current song".
      emit(state.copyWith(
        clearPlayingSong: true,
        isPlaying: false,
        errorMessage: ErrorMessage.from(e, 'Gagal memutar lagu'),
      ));
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
      emit(state.copyWith(myPlaylists: myPlaylists));
    } catch (e) {
      if (kDebugMode) debugPrint('Music: gagal membuat playlist: $e');
      emit(state.copyWith(
        errorMessage: ErrorMessage.from(e, 'Gagal membuat playlist'),
      ));
    }
  }

  Future<void> _onStopSongRequested(
    MusicStopSongRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        clearPlayingSong: true,
        isPlaying: false,
        position: Duration.zero,
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
        position: event.position,
        duration: event.duration,
      ),
    );
  }
}
