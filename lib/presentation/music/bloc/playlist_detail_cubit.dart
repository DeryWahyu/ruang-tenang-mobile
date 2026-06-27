import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/music.dart';
import '../../../domain/usecases/music/music_usecases.dart';

part 'playlist_detail_state.dart';

class PlaylistDetailCubit extends Cubit<PlaylistDetailState> {
  final GetPlaylistUseCase _getPlaylist;

  PlaylistDetailCubit(this._getPlaylist) : super(PlaylistDetailInitial());

  Future<void> fetchPlaylist(String uuid) async {
    emit(PlaylistDetailLoading());
    try {
      final playlist = await _getPlaylist(uuid);
      emit(PlaylistDetailLoaded(playlist));
    } catch (e) {
      emit(PlaylistDetailError(e.toString()));
    }
  }
}
