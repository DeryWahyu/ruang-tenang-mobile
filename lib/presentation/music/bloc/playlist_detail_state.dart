part of 'playlist_detail_cubit.dart';

abstract class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();

  @override
  List<Object?> get props => [];
}

class PlaylistDetailInitial extends PlaylistDetailState {}

class PlaylistDetailLoading extends PlaylistDetailState {}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final Playlist playlist;

  const PlaylistDetailLoaded(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class PlaylistDetailError extends PlaylistDetailState {
  final String message;

  const PlaylistDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
