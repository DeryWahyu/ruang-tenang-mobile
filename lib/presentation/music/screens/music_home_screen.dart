import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
    return BlocProvider(
      create: (context) => sl<MusicBloc>(),
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
                    image: song.thumbnail != null
                        ? DecorationImage(image: NetworkImage(song.thumbnail!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: song.thumbnail == null ? const Icon(Icons.music_note, color: AppColors.primary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Relaksasi', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  color: AppColors.primary,
                  iconSize: 32,
                  onPressed: () {
                    if (state.isPlaying) {
                      context.read<MusicBloc>().add(const MusicPauseSongRequested());
                    } else {
                      context.read<MusicBloc>().add(const MusicResumeSongRequested());
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop_rounded),
                  color: AppColors.mutedForeground,
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
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingBase,
        right: AppDimensions.spacingBase,
        top: AppDimensions.spacingBase,
        bottom: state.currentPlayingSong != null ? 100 : AppDimensions.spacingBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temukan Kedamaian',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final isSelected = true; // Todo: state logic for selected category
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: index == 0, // Mock selection
                    onSelected: (_) {
                      context.read<MusicBloc>().add(MusicCategorySelected(category.slug ?? category.id.toString()));
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: index == 0 ? Colors.white : AppColors.foreground,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (state.currentCategorySongs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Tidak ada lagu di kategori ini.', style: TextStyle(color: AppColors.mutedForeground)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.currentCategorySongs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final song = state.currentCategorySongs[index];
                final isPlaying = state.currentPlayingSong?.id == song.id;
                
                return InkWell(
                  onTap: () {
                    if (isPlaying) {
                      if (state.isPlaying) {
                        context.read<MusicBloc>().add(const MusicPauseSongRequested());
                      } else {
                        context.read<MusicBloc>().add(const MusicResumeSongRequested());
                      }
                    } else {
                      context.read<MusicBloc>().add(MusicPlaySongRequested(song.id!));
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isPlaying ? AppColors.primary.withOpacity(0.5) : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                            image: song.thumbnail != null
                                ? DecorationImage(image: NetworkImage(song.thumbnail!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: song.thumbnail == null ? const Icon(Icons.music_note, color: AppColors.primary) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPlaying ? AppColors.primary : AppColors.foreground),
                              ),
                              const SizedBox(height: 4),
                              const Text('Ruang Tenang', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPlaying ? AppColors.primary : AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            (isPlaying && state.isPlaying) ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: isPlaying ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context, MusicState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingBase,
        right: AppDimensions.spacingBase,
        top: AppDimensions.spacingBase,
        bottom: state.currentPlayingSong != null ? 100 : AppDimensions.spacingBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('MUSIC JOURNEY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ubah sesi dengar jadi pemulihan.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih journey lalu tutup dengan refleksi singkat.',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                        label: const Text('Refleksi', style: TextStyle(color: AppColors.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Playlist Publik',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground),
          ),
          const SizedBox(height: 16),
          if (state.publicPlaylists.isEmpty)
            const Text('Belum ada playlist publik.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: state.publicPlaylists.length,
              itemBuilder: (context, index) {
                final pl = state.publicPlaylists[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            image: pl.thumbnail != null
                                ? DecorationImage(image: NetworkImage(pl.thumbnail!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: pl.thumbnail == null ? const Center(child: Icon(Icons.queue_music, size: 40, color: AppColors.primary)) : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pl.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${pl.itemCount} Lagu', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTab(BuildContext context, MusicState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingBase,
        right: AppDimensions.spacingBase,
        top: AppDimensions.spacingBase,
        bottom: state.currentPlayingSong != null ? 100 : AppDimensions.spacingBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Koleksiku',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    _showCreatePlaylistDialog(context);
                  },
                  icon: const Icon(Icons.add, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.myPlaylists.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.queue_music_rounded, size: 80, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  const Text('Belum Ada Playlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Buat playlist pertamamu sekarang', style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.myPlaylists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pl = state.myPlaylists[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          image: pl.thumbnail != null
                              ? DecorationImage(image: NetworkImage(pl.thumbnail!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: pl.thumbnail == null ? const Icon(Icons.queue_music, color: AppColors.primary) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pl.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${pl.itemCount} Lagu', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;
    File? thumbnailFile;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Buat Playlist Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            thumbnailFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          image: thumbnailFile != null
                              ? DecorationImage(
                                  image: FileImage(thumbnailFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: thumbnailFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text('Pilih Cover', style: TextStyle(color: AppColors.mutedForeground)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Playlist',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Jadikan Publik'),
                      subtitle: const Text('Playlist bisa dilihat semua orang', style: TextStyle(fontSize: 12)),
                      value: isPublic,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          isPublic = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final desc = descriptionController.text.trim();
                    
                    if (name.isNotEmpty) {
                      context.read<MusicBloc>().add(MusicCreatePlaylistRequested(
                        name: name,
                        description: desc,
                        thumbnailFile: thumbnailFile,
                        isPublic: isPublic,
                      ));
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buat'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
