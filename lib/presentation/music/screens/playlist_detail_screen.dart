import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/music.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../bloc/playlist_detail_cubit.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String uuid;

  const PlaylistDetailScreen({super.key, required this.uuid});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late final PlaylistDetailCubit _cubit;
  late final MusicBloc _music;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PlaylistDetailCubit>();
    _music = sl<MusicBloc>();
    // Fetch after the first frame so we don't emit/mutate during the build
    // that the route push triggers — avoids MouseTracker reentrancy on desktop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.fetchPlaylist(widget.uuid);
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _back() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _music),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
            onPressed: _back,
          ),
          title: const Text('Detail Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
          builder: (context, state) {
            if (state is PlaylistDetailError) {
              return _centered(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat playlist',
                subtitle: state.message,
                onRetry: () => _cubit.fetchPlaylist(widget.uuid),
              );
            }
            if (state is PlaylistDetailLoaded) {
              return _content(state.playlist);
            }
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          },
        ),
      ),
    );
  }

  Widget _content(Playlist playlist) {
    final songs = playlist.items.where((i) => i.song != null).map((i) => i.song!).toList();
    final songCount = playlist.totalSongs > 0 ? playlist.totalSongs : playlist.itemCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: _cover(playlist.thumbnail)),
        const SizedBox(height: 20),
        Text(playlist.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if ((playlist.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(playlist.description!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground)),
        ],
        const SizedBox(height: 12),
        Center(
          child: Text('$songCount Lagu • ${playlist.isPublic ? "Publik" : "Privat"}',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        if (songs.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pillButton(
                icon: Icons.play_arrow_rounded,
                label: 'Putar Semua',
                filled: true,
                onTap: () => _music.add(MusicPlaySongRequested(songs.first)),
              ),
              const SizedBox(width: 12),
              _pillButton(
                icon: Icons.shuffle_rounded,
                label: 'Acak',
                filled: false,
                onTap: () {
                  final shuffled = List<Song>.from(songs)..shuffle();
                  _music.add(MusicPlaySongRequested(shuffled.first));
                },
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (songs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('Playlist ini belum punya lagu',
                  style: TextStyle(color: AppColors.mutedForeground)),
            ),
          )
        else
          BlocBuilder<MusicBloc, MusicState>(
            buildWhen: (p, c) =>
                p.currentPlayingSong?.id != c.currentPlayingSong?.id || p.isPlaying != c.isPlaying,
            builder: (context, ms) {
              return Column(
                children: songs.map((song) {
                  final isCurrent = ms.currentPlayingSong?.id == song.id;
                  return _songTile(song, isCurrent, ms.isPlaying);
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _songTile(Song song, bool isCurrent, bool isPlaying) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isCurrent) {
          _music.add(isPlaying ? const MusicPauseSongRequested() : const MusicResumeSongRequested());
        } else {
          _music.add(MusicPlaySongRequested(song));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCurrent ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
        ),
        child: Row(
          children: [
            _thumb(song.thumbnail, 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCurrent ? AppColors.primary : AppColors.foreground)),
                  const SizedBox(height: 2),
                  const Text('Ruang Tenang',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),
            Icon(isCurrent && isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: AppColors.primary, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: filled ? Colors.white : AppColors.primary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: filled ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _centered({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.mutedForeground),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedForeground)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cover(String? url) {
    return AppNetworkImage(
      url: url,
      width: 180,
      height: 180,
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.secondary,
      fallbackIcon: Icons.queue_music,
      fallbackColor: AppColors.primary,
    );
  }

  Widget _thumb(String? url, double size) {
    return AppNetworkImage(
      url: url,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColors.secondary,
      fallbackIcon: Icons.music_note,
      fallbackColor: AppColors.primary,
    );
  }
}
