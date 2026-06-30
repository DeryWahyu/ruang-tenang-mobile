import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../common/widgets/app_network_image.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';

/// Mini-player musik **global** yang mengikuti seluruh layar.
///
/// Dipasang sekali di atas navigator (lihat `app.dart`) dan memakai
/// [MusicBloc] singleton sehingga kontrol pemutaran tetap muncul saat
/// pengguna berpindah screen. Menyembunyikan diri bila tidak ada lagu
/// yang aktif. Mengetuknya membuka layar Musik penuh.
///
/// Parameter [bottomOffset] dipakai pemanggil untuk menaikkan posisi mini
/// player di atas bottom-nav/safe-area agar tidak tertutup.
class GlobalMiniPlayer extends StatelessWidget {
  final double bottomOffset;

  const GlobalMiniPlayer({super.key, this.bottomOffset = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MusicBloc>(),
      child: BlocBuilder<MusicBloc, MusicState>(
        // Bangun ulang hanya saat hal yang relevan untuk mini-player berubah.
        buildWhen: (p, c) =>
            p.currentPlayingSong != c.currentPlayingSong ||
            p.isPlaying != c.isPlaying ||
            p.position != c.position ||
            p.duration != c.duration,
        builder: (context, state) {
          final song = state.currentPlayingSong;
          if (song == null) return const SizedBox.shrink();

          final progress = state.duration.inMilliseconds > 0
              ? state.position.inMilliseconds / state.duration.inMilliseconds
              : 0.0;

          return Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, bottomOffset),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/music'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    boxShadow: AppShadows.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppColors.secondary,
                          color: AppColors.primary,
                          minHeight: 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            _thumb(song.thumbnail, 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const Text('Ruang Tenang',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: AppColors.primary,
                                size: 34,
                              ),
                              onPressed: () => context.read<MusicBloc>().add(
                                    state.isPlaying
                                        ? const MusicPauseSongRequested()
                                        : const MusicResumeSongRequested(),
                                  ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close_rounded, color: AppColors.mutedForeground, size: 22),
                              onPressed: () => context.read<MusicBloc>().add(const MusicStopSongRequested()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _thumb(String? url, double size) {
    return AppNetworkImage(
      url: url,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: AppColors.secondary,
      fallbackIcon: Icons.music_note,
      fallbackColor: AppColors.primary,
    );
  }
}
