import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/chat.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/app_skeleton.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_detail_screen.dart' show kChatSuggestions;
import '../../common/widgets/mascot_hero.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _search = TextEditingController();
  final ApiClient _api = sl<ApiClient>();
  String _filter = 'all';

  void _refresh() => context.read<ChatBloc>().add(
    ChatSessionsRequested(
      refresh: true,
      filter: _filter,
      search: _search.text.trim(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      context.read<ChatBloc>().add(
        ChatSessionsLoadMoreRequested(
          filter: _filter,
          search: _search.text.trim(),
        ),
      );
    }
  }

  void _openNewChat({String? prompt}) {
    // Langsung masuk ke layar obrolan baru tanpa meminta judul terlebih
    // dahulu (mirip GPT/Gemini/Claude). Judul dibuat otomatis dari pesan
    // pertama. Prompt opsional diteruskan sebagai teks awal input.
    context.push('/chat/new', extra: prompt).then((_) {
      if (mounted) {
        _refresh();
      }
    });
  }

  void _openSession(String uuid) {
    context.push('/chat/$uuid').then((_) {
      if (mounted) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konseling AI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Teman cerita virtual Anda',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Kelola folder',
            onPressed: _manageFolders,
            icon: const Icon(Icons.folder_outlined),
          ),
        ],
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewChat(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.maps_ugc_rounded),
        label: const Text(
          'Obrolan Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.status == ChatStatus.failure && state.sessions.isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat sesi obrolan',
              onRetry: _refresh,
            );
          }

          final loadingInitial = state.isLoading && state.sessions.isEmpty;

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () async => _refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 600,
              slivers: [
                SliverToBoxAdapter(child: _hero()),
                SliverToBoxAdapter(child: _suggestions()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TextField(
                      controller: _search,
                      onSubmitted: (_) => _refresh(),
                      decoration: InputDecoration(
                        hintText: 'Cari obrolan',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _search.clear();
                            _refresh();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: _filter == 'all',
                          onSelected: (_) {
                            setState(() => _filter = 'all');
                            _refresh();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Favorit'),
                          selected: _filter == 'favorites',
                          onSelected: (_) {
                            setState(() => _filter = 'favorites');
                            _refresh();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Sampah'),
                          selected: _filter == 'trash',
                          onSelected: (_) {
                            setState(() => _filter = 'trash');
                            _refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _sectionHeader()),
                if (loadingInitial)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: AppSkeleton(
                            height: 76,
                            borderRadius: AppDimensions.radiusLg,
                          ),
                        ),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (state.sessions.isEmpty)
                  SliverToBoxAdapter(child: _emptyHint())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.sessions.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: AppLoadingIndicator(size: 24),
                              ),
                            );
                          }
                          return _sessionCard(state.sessions[index]);
                        },
                        childCount:
                            state.sessions.length + (state.hasNextPage ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: const MascotHero(
        title: 'Teman Cerita AI',
        description: 'RuNa siap menemanimu bercerita, tanpa menghakimi.',
        pose: 'chat-listen',
      ),
    );
  }

  Widget _suggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 6),
              Text(
                'Mulai cepat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kChatSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = kChatSuggestions[i];
              return _chip(s);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _chip(String text) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openNewChat(prompt: text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        'Riwayat Obrolan',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _emptyHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 44,
              color: AppColors.mutedForeground.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada obrolan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai percakapan pertamamu lewat tombol di atas atau pilih topik cepat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(ChatSessionListItem session) {
    final dateStr = DateFormat('dd MMM yyyy').format(session.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openSession(session.uuid),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFB7185),
                        Color(0xFFEF4444),
                        Color(0xFFDC2626),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _sessionAction(session, action),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'favorite',
                      child: Text(
                        session.isFavorite
                            ? 'Hapus favorit'
                            : 'Jadikan favorit',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'folder',
                      child: Text('Pindah ke folder'),
                    ),
                    PopupMenuItem(
                      value: 'trash',
                      child: Text(
                        session.isTrash ? 'Pulihkan' : 'Pindah ke sampah',
                      ),
                    ),
                    if (session.isTrash)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus permanen'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _folders() async {
    final response = await _api.get<List<dynamic>>(
      '/chat-folders',
      fromJson: (value) => value as List<dynamic>,
    );
    if (!response.success) throw Exception(response.error);
    return (response.data ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _sessionAction(
    ChatSessionListItem session,
    String action,
  ) async {
    try {
      if (action == 'folder') {
        final folders = await _folders();
        if (!mounted) return;
        final folderId = await showModalBottomSheet<int>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(title: Text('Pindah ke folder')),
                ListTile(
                  title: const Text('Tanpa folder'),
                  onTap: () => Navigator.pop(sheetContext, -1),
                ),
                ...folders.map(
                  (folder) => ListTile(
                    title: Text(folder['name']?.toString() ?? ''),
                    onTap: () =>
                        Navigator.pop(sheetContext, folder['id'] as int),
                  ),
                ),
              ],
            ),
          ),
        );
        if (folderId == null) return;
        final response = await _api.put<dynamic>(
          '/chat-sessions/${session.uuid}/folder',
          data: {'folder_id': folderId == -1 ? null : folderId},
        );
        if (!response.success) throw Exception(response.error);
      } else if (action == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Hapus obrolan permanen?'),
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
        final response = await _api.delete<dynamic>(
          '/chat-sessions/${session.uuid}',
        );
        if (!response.success) throw Exception(response.error);
      } else {
        final path = action == 'favorite' ? 'favorite' : 'trash';
        final response = await _api.put<dynamic>(
          '/chat-sessions/${session.uuid}/$path',
        );
        if (!response.success) throw Exception(response.error);
      }
      if (mounted) _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan obrolan belum berhasil disimpan.'),
          ),
        );
      }
    }
  }

  Future<void> _manageFolders() async {
    try {
      final folders = await _folders();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Folder obrolan')),
              ...folders.map(
                (folder) => ListTile(
                  title: Text(folder['name']?.toString() ?? ''),
                  subtitle: Text('${folder['session_count'] ?? 0} obrolan'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      Navigator.pop(sheetContext);
                      await _editFolder(folder, delete: action == 'delete');
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah nama')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus folder'),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Buat folder'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editFolder(null);
                },
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder belum berhasil dimuat.')),
        );
      }
    }
  }

  Future<void> _editFolder(
    Map<String, dynamic>? folder, {
    bool delete = false,
  }) async {
    if (delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hapus folder?'),
          content: const Text('Obrolan di dalamnya tetap tersimpan.'),
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
        await _api.delete<dynamic>('/chat-folders/${folder!['id']}');
        if (mounted) _manageFolders();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder belum berhasil dihapus.')),
          );
        }
      }
      return;
    }
    final name = TextEditingController(text: folder?['name']?.toString() ?? '');
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(folder == null ? 'Buat folder' : 'Ubah nama folder'),
        content: TextField(
          controller: name,
          maxLength: 100,
          decoration: const InputDecoration(labelText: 'Nama folder'),
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
    );
    if (save == true && name.text.trim().isNotEmpty) {
      try {
        if (folder == null) {
          await _api.post<dynamic>(
            '/chat-folders',
            data: {'name': name.text.trim()},
          );
        } else {
          await _api.put<dynamic>(
            '/chat-folders/${folder['id']}',
            data: {'name': name.text.trim()},
          );
        }
        if (mounted) _manageFolders();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder belum berhasil disimpan.')),
          );
        }
      }
    }
    name.dispose();
  }
}
