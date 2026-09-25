import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_alert_dialog.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/music.dart';
import '../../../domain/repositories/music_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../bloc/playlist_detail_cubit.dart';
import '../widgets/track_attribution.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String uuid;

  const PlaylistDetailScreen({super.key, required this.uuid});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late final PlaylistDetailCubit _cubit;
  late final MusicBloc _music;
  final MusicRepository _repository = sl<MusicRepository>();

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
          title: const Text(
            'Detail Playlist',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              return BlocBuilder<MusicBloc, MusicState>(
                buildWhen: (previous, current) =>
                    (previous.currentPlayingSong == null) !=
                    (current.currentPlayingSong == null),
                builder: (context, musicState) => _content(
                  state.playlist,
                  hasPlayer: musicState.currentPlayingSong != null,
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          },
        ),
      ),
    );
  }

  Widget _content(Playlist playlist, {required bool hasPlayer}) {
    final songs = playlist.items
        .where((i) => i.song != null)
        .map((i) => i.song!)
        .toList();
    final songCount = playlist.totalSongs > 0
        ? playlist.totalSongs
        : playlist.itemCount;
    final own =
        playlist.userId == context.read<AuthBloc>().state.user?.id &&
        !playlist.isAdminPlaylist;

    final bottomClearance =
        MediaQuery.of(context).padding.bottom + (hasPlayer ? 112.0 : 28.0);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomClearance),
      children: [
        Center(child: _cover(playlist.thumbnail)),
        const SizedBox(height: 20),
        Text(
          playlist.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if ((playlist.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            playlist.description!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
        ],
        const SizedBox(height: 12),
        Center(
          child: Text(
            '$songCount Lagu • ${playlist.isPublic ? "Publik" : "Privat"}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (own) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editPlaylist(playlist),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: _addSong,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                icon: const Icon(Icons.add),
                label: const Text('Tambah lagu'),
              ),
              TextButton.icon(
                onPressed: () => _deletePlaylist(playlist),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (songs.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _pillButton(
                icon: Icons.play_arrow_rounded,
                label: 'Putar Semua',
                filled: true,
                onTap: () => _music.add(MusicPlayQueueRequested(songs)),
              ),
              _pillButton(
                icon: Icons.shuffle_rounded,
                label: 'Acak',
                filled: false,
                onTap: () {
                  final shuffled = List<Song>.from(songs)..shuffle();
                  _music.add(MusicPlayQueueRequested(shuffled));
                },
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (songs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Playlist ini belum punya lagu',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          )
        else
          BlocBuilder<MusicBloc, MusicState>(
            buildWhen: (p, c) =>
                p.currentPlayingSong?.id != c.currentPlayingSong?.id ||
                p.isPlaying != c.isPlaying ||
                p.isBuffering != c.isBuffering,
            builder: (context, ms) {
              return Column(
                children: songs.map((song) {
                  final isCurrent = ms.currentPlayingSong?.id == song.id;
                  return _songTile(song, isCurrent, ms.isPlaying, own);
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _songTile(Song song, bool isCurrent, bool isPlaying, bool own) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isCurrent) {
              _music.add(
                isPlaying || _music.state.isBuffering
                    ? const MusicPauseSongRequested()
                    : const MusicResumeSongRequested(),
              );
            } else {
              _music.add(MusicPlaySongRequested(song));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _thumb(song.thumbnail, 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TrackAttribution(song: song),
                    ],
                  ),
                ),
                if (isCurrent && _music.state.isBuffering)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    isCurrent && isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: AppColors.primary,
                    size: 30,
                  ),
                if (own)
                  IconButton(
                    tooltip: 'Hapus dari playlist',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeSong(song),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editPlaylist(Playlist playlist) async {
    final name = TextEditingController(text: playlist.name);
    final description = TextEditingController(text: playlist.description ?? '');
    var isPublic = playlist.isPublic;
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => AppAlertDialog(
          title: const Text('Edit playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              SwitchListTile(
                value: isPublic,
                title: const Text('Publik'),
                onChanged: (value) => update(() => isPublic = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (save == true && name.text.trim().isNotEmpty) {
      try {
        await _repository.updatePlaylist(
          widget.uuid,
          name: name.text.trim(),
          description: description.text.trim(),
          thumbnail: playlist.thumbnail ?? '',
          isPublic: isPublic,
        );
        _cubit.fetchPlaylist(widget.uuid);
      } catch (_) {
        _showError('Playlist belum berhasil diubah.');
      }
    }
    name.dispose();
    description.dispose();
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: const Text('Hapus playlist?'),
        content: Text(playlist.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deletePlaylist(widget.uuid);
      if (mounted) context.pop();
    } catch (_) {
      _showError('Playlist belum berhasil dihapus.');
    }
  }

  Future<void> _removeSong(Song song) async {
    try {
      await _repository.removeSong(widget.uuid, song.id);
      _cubit.fetchPlaylist(widget.uuid);
    } catch (_) {
      _showError('Lagu belum berhasil dihapus.');
    }
  }

  Future<void> _addSong() async {
    try {
      final categories = await _repository.getSongCategories();
      if (categories.isEmpty || !mounted) return;
      var selected = categories.first;
      var songs = await _repository.getSongsByCategory(selected.slug ?? '');
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, update) => SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const ListTile(title: Text('Tambah lagu')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<int>(
                      initialValue: selected.id,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: categories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) async {
                        selected = categories.firstWhere(
                          (item) => item.id == id,
                        );
                        final loaded = await _repository.getSongsByCategory(
                          selected.slug ?? '',
                        );
                        update(() => songs = loaded);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: songs
                          .map(
                            (song) => ListTile(
                              title: Text(song.title),
                              trailing: const Icon(Icons.add),
                              onTap: () async {
                                try {
                                  await _repository.addSong(
                                    widget.uuid,
                                    song.id,
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                  _cubit.fetchPlaylist(widget.uuid);
                                } catch (_) {
                                  _showError(
                                    'Lagu belum berhasil ditambahkan.',
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      _showError('Daftar lagu belum berhasil dimuat.');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
            Icon(
              icon,
              size: 18,
              color: filled ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
