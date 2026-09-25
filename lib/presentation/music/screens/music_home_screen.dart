import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/music.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../widgets/track_attribution.dart';
import '../../common/widgets/mascot_hero.dart';

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

class _MusicHomeViewState extends State<_MusicHomeView>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Musik Relaksasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
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
              onRetry: () => context.read<MusicBloc>().add(
                const MusicFetchInitialDataRequested(),
              ),
            );
          }

          final hasPlayer = state.currentPlayingSong != null;
          // Mini-player kini dirender global oleh shell (MainLayout), jadi
          // beri ruang bawah saja agar konten tidak tertutup pemutar.
          final bottomPad = hasPlayer ? 96.0 : 16.0;
          return SizedBox.expand(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(context, state, bottomPad),
                _buildExploreTab(context, state, bottomPad),
                _buildPlaylistTab(context, state, bottomPad),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== Browse tab: expandable categories =====
  Widget _buildBrowseTab(
    BuildContext context,
    MusicState state,
    double bottomPad,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        bottomPad,
      ),
      children: [
        const MascotHero(
          title: 'Musik yang menemani',
          description: 'Pilih irama untuk fokus, bernapas, atau beristirahat.',
          pose: 'music-headphones',
          overflowMascot: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Kategori Musik',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (state.categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Belum ada kategori',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          )
        else
          ...state.categories.map(
            (category) => _categoryTile(context, category, state),
          ),
      ],
    );
  }

  Widget _categoryTile(
    BuildContext context,
    SongCategory category,
    MusicState state,
  ) {
    final slug = category.slug ?? '';
    final isExpanded = _expandedSlug == slug && slug.isNotEmpty;
    final categoryIsSelected = state.selectedCategorySlug == slug;
    final songs = categoryIsSelected
        ? state.currentCategorySongs
        : const <Song>[];
    final isLoadingSongs = categoryIsSelected && state.isLoadingCategorySongs;
    final categoryError = categoryIsSelected
        ? state.categoryErrorMessage
        : null;

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
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${category.songCount} lagu',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: isLoadingSongs
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : categoryError != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: AppColors.mutedForeground,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              categoryError,
                              style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.read<MusicBloc>().add(
                              MusicCategorySelected(slug),
                            ),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  : songs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Belum ada lagu di kategori ini.',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    )
                  : Column(
                      children: songs
                          .map((s) => _songRow(context, s, state))
                          .toList(),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _songRow(BuildContext context, Song song, MusicState state) {
    final isCurrent = state.currentPlayingSong?.id == song.id;
    final isPlaying = isCurrent && state.isPlaying;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final bloc = context.read<MusicBloc>();
          if (isCurrent) {
            bloc.add(
              isPlaying || state.isBuffering
                  ? const MusicPauseSongRequested()
                  : const MusicResumeSongRequested(),
            );
          } else {
            bloc.add(MusicPlaySongRequested(song));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              _thumb(song.thumbnail, Icons.music_note, 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.foreground,
                      ),
                    ),
                    TrackAttribution(song: song),
                  ],
                ),
              ),
              if (isCurrent && state.isBuffering)
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
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_arrow_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Explore tab: public playlists =====
  Widget _buildExploreTab(
    BuildContext context,
    MusicState state,
    double bottomPad,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        bottomPad,
      ),
      children: [
        const MascotHero(
          title: 'Temukan irama jedamu',
          description: 'Jelajahi playlist pilihan untuk menemani waktu tenang.',
          pose: 'tour-music',
          overflowMascot: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Playlist Publik',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (state.publicPlaylists.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Belum ada playlist publik',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          )
        else
          ...state.publicPlaylists.map((p) => _playlistCard(context, p)),
      ],
    );
  }

  // ===== Playlist tab: my playlists =====
  Widget _buildPlaylistTab(
    BuildContext context,
    MusicState state,
    double bottomPad,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
        bottomPad,
      ),
      children: [
        const MascotHero(
          title: 'Simpan musik favorit',
          description: 'Buat playlist pribadi untuk menemani rutinitasmu.',
          pose: 'music-headphones',
          overflowMascot: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Playlist Saya',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showCreatePlaylistDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Buat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                const Icon(
                  Icons.queue_music_rounded,
                  size: 56,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada playlist',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Buat playlist pertamamu untuk menyimpan lagu favorit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
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
      padding: const EdgeInsets.all(12.0),
      onTap: () => _openPlaylist(playlist.uuid),
      child: Row(
        children: [
          _thumb(playlist.thumbnail, Icons.queue_music, 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if ((playlist.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    playlist.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      size: 14,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${playlist.itemCount} lagu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    if (playlist.isPublic) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.public,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Publik',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ],
      ),
    );
  }

  /// Builds a thumbnail box. Relative image paths from the API are resolved to
  /// absolute URLs so covers also load on mobile (not just full http URLs).
  Widget _thumb(String? url, IconData fallbackIcon, double size) {
    return AppNetworkImage(
      url: url,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColors.secondary,
      fallbackIcon: fallbackIcon,
      fallbackColor: AppColors.primary,
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

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final bloc = context.read<MusicBloc>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var nameError = false;
        return StatefulBuilder(
          builder: (dialogContext, update) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _playlistDialogHeader(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NAMA PLAYLIST',
                                  style: TextStyle(
                                    color: AppColors.gray700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                TextField(
                                  controller: nameController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (nameError) {
                                      update(() => nameError = false);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Contoh: Waktu istirahat',
                                    prefixIcon: const Icon(
                                      Icons.music_note_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    errorText: nameError
                                        ? 'Nama playlist wajib diisi'
                                        : null,
                                    filled: true,
                                    fillColor: const Color(0xFFFFFAFA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 15,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE8E8ED),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.destructive,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.destructive,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 17),
                                const Text(
                                  'DESKRIPSI',
                                  style: TextStyle(
                                    color: AppColors.gray700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                TextField(
                                  controller: descController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  minLines: 3,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    hintText: 'Ceritakan suasana playlist ini…',
                                    alignLabelWithHint: true,
                                    filled: true,
                                    fillColor: const Color(0xFFFFFAFA),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      15,
                                      14,
                                      15,
                                      14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE8E8ED),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF6F5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFFBE1DF),
                                    ),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        color: AppColors.primary,
                                        size: 17,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Playlist ini bersifat pribadi dan hanya terlihat olehmu.',
                                          style: TextStyle(
                                            color: AppColors.gray700,
                                            fontSize: 10,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 19),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.gray600,
                                        minimumSize: const Size(72, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Batal'),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          final name = nameController.text
                                              .trim();
                                          if (name.isEmpty) {
                                            update(() => nameError = true);
                                            return;
                                          }
                                          bloc.add(
                                            MusicCreatePlaylistRequested(
                                              name: name,
                                              description: descController.text
                                                  .trim(),
                                              isPublic: false,
                                            ),
                                          );
                                          Navigator.pop(dialogContext);
                                        },
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(0, 48),
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shadowColor: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 19,
                                        ),
                                        label: const Text('Buat playlist'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: -18,
                    width: 118,
                    height: 158,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/images/mascot/music-headphones.webp',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    nameController.dispose();
    descController.dispose();
  }

  Widget _playlistDialogHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(22, 22, 116, 22),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF65A5D), Color(0xFFE94249)],
      ),
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -90,
          top: -77,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.graphic_eq_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'MUSIK UNTUKMU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'Buat playlist baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Simpan lagu yang ingin kamu dengarkan lagi.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
