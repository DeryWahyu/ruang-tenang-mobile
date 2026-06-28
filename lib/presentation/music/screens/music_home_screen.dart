import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/music.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';

class MusicHomeScreen extends StatelessWidget {
  const MusicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MusicBloc>(),
      child: const _MusicHomeView(),
    );
  }
}

class _MusicHomeView extends StatefulWidget {
  const _MusicHomeView();

  @override
  State<_MusicHomeView> createState() => _MusicHomeViewState();
}

class _MusicHomeViewState extends State<_MusicHomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedSlug;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<MusicBloc>().add(const MusicFetchInitialDataRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Musik Relaksasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.border,
          tabs: const [
            Tab(text: 'Jelajahi'),
            Tab(text: 'Eksplorasi'),
            Tab(text: 'Playlist'),
          ],
        ),
      ),
      body: BlocBuilder<MusicBloc, MusicState>(
        builder: (context, state) {
          if (state.status == MusicStatus.loading) {
            return const Center(child: AppLoadingIndicator());
          }
          if (state.status == MusicStatus.failure) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat musik',
              onRetry: () => context.read<MusicBloc>().add(const MusicFetchInitialDataRequested()),
            );
          }

          final hasPlayer = state.currentPlayingSong != null;
          final bottomPad = hasPlayer ? 96.0 : 16.0;
          return SizedBox.expand(
            child: Stack(
              children: [
                Positioned.fill(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBrowseTab(context, state, bottomPad),
                      _buildExploreTab(context, state, bottomPad),
                      _buildPlaylistTab(context, state, bottomPad),
                    ],
                  ),
                ),
                if (hasPlayer)
                  Positioned(left: 0, right: 0, bottom: 0, child: _buildMiniPlayer(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== Browse tab: expandable categories =====
  Widget _buildBrowseTab(BuildContext context, MusicState state, double bottomPad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(AppDimensions.spacingBase, AppDimensions.spacingBase, AppDimensions.spacingBase, bottomPad),
      children: [
        const Text('Kategori Musik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (state.categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('Belum ada kategori', style: TextStyle(color: AppColors.mutedForeground))),
          )
        else
          ...state.categories.map((category) => _categoryTile(context, category, state)),
      ],
    );
  }

  Widget _categoryTile(BuildContext context, SongCategory category, MusicState state) {
    final slug = category.slug ?? '';
    final isExpanded = _expandedSlug == slug && slug.isNotEmpty;
    final songs = isExpanded ? state.currentCategorySongs : const <Song>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _expandedSlug = isExpanded ? null : slug);
                if (!isExpanded && slug.isNotEmpty) {
                  context.read<MusicBloc>().add(MusicCategorySelected(slug));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _thumb(category.thumbnail, Icons.music_note, 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${category.songCount} lagu',
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: AppColors.mutedForeground),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: songs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                          child: SizedBox(
                              width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                    )
                  : Column(children: songs.map((s) => _songRow(context, s, state)).toList()),
            ),
        ],
      ),
    );
  }

  Widget _songRow(BuildContext context, Song song, MusicState state) {
    final isPlaying = state.currentPlayingSong?.id == song.id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.read<MusicBloc>().add(MusicPlaySongRequested(song)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              _thumb(song.thumbnail, Icons.music_note, 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPlaying ? AppColors.primary : AppColors.foreground)),
              ),
              Icon(isPlaying && state.isPlaying ? Icons.pause_circle_filled : Icons.play_arrow_rounded,
                  color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Explore tab: public playlists =====
  Widget _buildExploreTab(BuildContext context, MusicState state, double bottomPad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(AppDimensions.spacingBase, AppDimensions.spacingBase, AppDimensions.spacingBase, bottomPad),
      children: [
        const Text('Playlist Publik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (state.publicPlaylists.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('Belum ada playlist publik', style: TextStyle(color: AppColors.mutedForeground))),
          )
        else
          ...state.publicPlaylists.map((p) => _playlistCard(context, p)),
      ],
    );
  }

  // ===== Playlist tab: my playlists =====
  Widget _buildPlaylistTab(BuildContext context, MusicState state, double bottomPad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(AppDimensions.spacingBase, AppDimensions.spacingBase, AppDimensions.spacingBase, bottomPad),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Playlist Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showCreatePlaylistDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Buat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.myPlaylists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Icon(Icons.queue_music_rounded, size: 56, color: AppColors.mutedForeground),
                const SizedBox(height: 12),
                const Text('Belum ada playlist', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Buat playlist pertamamu untuk menyimpan lagu favorit.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          )
        else
          ...state.myPlaylists.map((p) => _playlistCard(context, p)),
      ],
    );
  }

  Widget _playlistCard(BuildContext context, PlaylistListItem playlist) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () => _openPlaylist(playlist.uuid),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _thumb(playlist.thumbnail, Icons.queue_music, 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if ((playlist.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(playlist.description!,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.music_note, size: 14, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text('${playlist.itemCount} lagu',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      if (playlist.isPublic) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.public, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        const Text('Publik', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }

  /// Builds a thumbnail box that only uses a network image for valid http URLs,
  /// avoiding broken-image issues with relative/empty paths.
  Widget _thumb(String? url, IconData fallbackIcon, double size) {
    final hasImage = url != null && url.startsWith('http');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: AppColors.primary, size: size * 0.5),
            )
          : Icon(fallbackIcon, color: AppColors.primary, size: size * 0.5),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, MusicState state) {
    final song = state.currentPlayingSong!;
    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
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
              minHeight: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _thumb(song.thumbnail, Icons.music_note, 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Ruang Tenang',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: AppColors.primary, size: 36),
                  onPressed: () => context.read<MusicBloc>().add(
                        state.isPlaying ? const MusicPauseSongRequested() : const MusicResumeSongRequested(),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.mutedForeground),
                  onPressed: () => context.read<MusicBloc>().add(const MusicStopSongRequested()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the playlist detail after the current frame. Deferring avoids
  /// mutating the widget tree synchronously inside the pointer/hover event,
  /// which triggers MouseTracker reentrancy assertions on desktop/web.
  void _openPlaylist(String? uuid) {
    if (uuid == null || uuid.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.push('/music/playlist/$uuid');
    });
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final bloc = context.read<MusicBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Buat Playlist Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Playlist', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  bloc.add(MusicCreatePlaylistRequested(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    isPublic: false,
                  ));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
  }
}
