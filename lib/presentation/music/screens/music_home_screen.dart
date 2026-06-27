import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../../core/di/injection_container.dart';
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

          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseTab(context, state),
                  _buildExploreTab(context, state),
                  _buildPlaylistTab(context, state),
                ],
              ),
              if (state.currentPlayingSong != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildMiniPlayer(context, state),
                ),
            ],
          );
        },
      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    image: song.thumbnail.isNotEmpty
                        ? DecorationImage(image: NetworkImage(song.thumbnail), fit: BoxFit.cover)
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ruang Tenang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  onPressed: () {
                    context.read<MusicBloc>().add(
                          state.isPlaying
                              ? const MusicPauseSongRequested()
                              : const MusicResumeSongRequested(),
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.mutedForeground),
                  onPressed: () {
                    context.read<MusicBloc>().add(const MusicStopSongRequested());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab(BuildContext context, MusicState state) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      children: [
        const Text(
          'Kategori Musik',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (state.categories.isEmpty)
          const Center(child: Text('Belum ada kategori'))
        else
          ...state.categories.map((category) {
            return InkWell(
              onTap: () {
                context.read<MusicBloc>().add(MusicCategorySelected(category.slug ?? ''));
              },
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          image: category.thumbnail.isNotEmpty
                              ? DecorationImage(image: NetworkImage(category.thumbnail), fit: BoxFit.cover)
                              : null,
                        ),
                        child: category.thumbnail.isEmpty
                            ? const Icon(Icons.music_note, size: 32, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category.songCount} lagu',
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          }),
        if (state.currentCategorySongs.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Lagu Tersedia',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...state.currentCategorySongs.map((song) {
            return AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              onTap: () {
                context.read<MusicBloc>().add(MusicPlaySongRequested(song));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                        image: song.thumbnail.isNotEmpty
                            ? DecorationImage(image: NetworkImage(song.thumbnail), fit: BoxFit.cover)
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_arrow, color: AppColors.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildExploreTab(BuildContext context, MusicState state) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      children: [
        const Text(
          'Playlist Publik',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (state.publicPlaylists.isEmpty)
          const Center(child: Text('Belum ada playlist publik'))
        else
          ...state.publicPlaylists.map((playlist) {
            return AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              onTap: () {
                if (playlist.uuid != null) {
                  context.push('/music/playlist/${playlist.uuid}');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        image: (playlist.thumbnail?.isNotEmpty ?? false)
                            ? DecorationImage(image: NetworkImage(playlist.thumbnail!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (playlist.thumbnail == null || playlist.thumbnail!.isEmpty)
                          ? const Icon(Icons.queue_music, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (playlist.description != null && playlist.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              playlist.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.music_note, size: 14, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                '${playlist.itemCount} lagu',
                                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                              ),
                              const SizedBox(width: 12),
                              if (playlist.isPublic) ...[
                                const Icon(Icons.public, size: 14, color: AppColors.mutedForeground),
                                const SizedBox(width: 4),
                                const Text(
                                  'Publik',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPlaylistTab(BuildContext context, MusicState state) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Playlist Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Buat Playlist'),
              onPressed: () {
                _showCreatePlaylistDialog(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.myPlaylists.isEmpty)
          const Center(child: Text('Belum ada playlist'))
        else
          ...state.myPlaylists.map((playlist) {
            return AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              onTap: () {
                if (playlist.uuid != null) {
                  context.push('/music/playlist/${playlist.uuid}');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        image: (playlist.thumbnail?.isNotEmpty ?? false)
                            ? DecorationImage(image: NetworkImage(playlist.thumbnail!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (playlist.thumbnail == null || playlist.thumbnail!.isEmpty)
                          ? const Icon(Icons.queue_music, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (playlist.description != null && playlist.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              playlist.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.music_note, size: 14, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                '${playlist.itemCount} lagu',
                                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                              ),
                              const SizedBox(width: 12),
                              if (playlist.isPublic) ...[
                                const Icon(Icons.public, size: 14, color: AppColors.mutedForeground),
                                const SizedBox(width: 4),
                                const Text(
                                  'Publik',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Playlist Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Playlist',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<MusicBloc>().add(
                    MusicCreatePlaylistRequested(
                      name: nameController.text,
                      description: descController.text,
                      isPublic: false,
                    ),
                  );
                  Navigator.pop(context);
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