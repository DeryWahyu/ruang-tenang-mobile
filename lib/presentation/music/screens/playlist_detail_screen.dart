import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../bloc/playlist_detail_cubit.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String uuid;

  const PlaylistDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<PlaylistDetailCubit>()..fetchPlaylist(uuid),
        ),
        BlocProvider.value(
          value: sl<MusicBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
            onPressed: () => context.pop(),
          ),
          title: const Text('Detail Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
          builder: (context, state) {
            if (state is PlaylistDetailLoading) {
              return const Center(child: AppLoadingIndicator());
            }
            if (state is PlaylistDetailError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<PlaylistDetailCubit>().fetchPlaylist(uuid),
              );
            }
            if (state is PlaylistDetailLoaded) {
              final playlist = state.playlist;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingBase),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(24),
                              image: (playlist.thumbnail?.isNotEmpty ?? false)
                                  ? DecorationImage(
                                      image: NetworkImage(playlist.thumbnail!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: (playlist.thumbnail?.isEmpty ?? true)
                                ? const Icon(Icons.queue_music, size: 80, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            playlist.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (playlist.description?.isNotEmpty ?? false)
                            Text(
                              playlist.description!,
                              style: const TextStyle(color: AppColors.mutedForeground),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 16),
                          Text(
                            '${playlist.totalSongs > 0 ? playlist.totalSongs : playlist.itemCount} Lagu • ${playlist.isPublic ? "Publik" : "Privat"}',
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  final firstSong = playlist.items
                                      .where((item) => item.song != null)
                                      .map((item) => item.song!)
                                      .firstOrNull;
                                  if (firstSong != null) {
                                    context.read<MusicBloc>().add(MusicPlaySongRequested(firstSong));
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Putar Semua'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  final songs = playlist.items
                                      .where((item) => item.song != null)
                                      .map((item) => item.song!)
                                      .toList()
                                    ..shuffle();
                                  if (songs.isNotEmpty) {
                                    context.read<MusicBloc>().add(MusicPlaySongRequested(songs.first));
                                  }
                                },
                                icon: const Icon(Icons.shuffle),
                                label: const Text('Acak'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= playlist.items.length) return null;
                        final item = playlist.items[index];
                        final song = item.song;
                        if (song == null) return const SizedBox();
                        
                        return BlocBuilder<MusicBloc, MusicState>(
                          builder: (context, musicState) {
                            final isPlaying = musicState.currentPlayingSong?.id == song.id;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingBase,
                                vertical: 4,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPlaying ? AppColors.primary.withOpacity(0.1) : AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isPlaying ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (isPlaying) {
                                      if (musicState.isPlaying) {
                                        context.read<MusicBloc>().add(const MusicPauseSongRequested());
                                      } else {
                                        context.read<MusicBloc>().add(const MusicResumeSongRequested());
                                      }
                                    } else {
                                      context.read<MusicBloc>().add(MusicPlaySongRequested(song));
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(12),
                                            image: song.thumbnail.isNotEmpty
                                                ? DecorationImage(
                                                    image: NetworkImage(song.thumbnail),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: song.thumbnail.isEmpty
                                              ? const Icon(Icons.music_note, color: AppColors.primary)
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isPlaying ? AppColors.primary : AppColors.foreground,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Ruang Tenang',
                                                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isPlaying)
                                          Icon(
                                            musicState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                            color: AppColors.primary,
                                            size: 32,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: playlist.items.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}