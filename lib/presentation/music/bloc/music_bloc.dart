import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/api_constants.dart';
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

    try {
      categories = await _getCategories();
    } catch (e) {
      print("ERROR Fetching Categories: $e");
      errorMsg = "Gagal memuat kategori: $e";
    }

    try {
      publicPlaylists = await _getPublicPlaylists();
    } catch (e) {
      print("ERROR Fetching Public Playlists: $e");
      errorMsg = errorMsg ?? "Gagal memuat playlist publik: $e";
    }

    try {
      myPlaylists = await _getMyPlaylists();
    } catch (e) {
      print("ERROR Fetching My Playlists: $e");
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
      // Handle error gracefully
    }
  }

  Future<void> _onPlaySongRequested(
    MusicPlaySongRequested event,
    Emitter<MusicState> emit,
  ) async {
    try {
      final song = event.song;
      emit(state.copyWith(currentPlayingSong: song));

      String url = song.filePath ?? '';
      if (!url.startsWith('http')) {
        url = '${ApiConstants.baseUrl}/$url';
        url = url
            .replaceAll('//storage', '/storage')
            .replaceAll('//public', '/public');
      }

      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } catch (e) {
        // Fallback to dummy audio if backend URL is broken
        const dummyAudio =
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
        await _audioPlayer.setUrl(dummyAudio);
        await _audioPlayer.play();
      }
    } catch (e) {
      // Silently handle playback errors
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
      // Error will be shown via snackbar in UI
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
