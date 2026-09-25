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
import '../../common/widgets/app_alert_dialog.dart';
import '../../common/widgets/app_search_bar.dart';

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
              'Teman Cerita',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              'Ruang aman untuk bercerita',
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Kelola folder',
              onPressed: _manageFolders,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.foreground,
              ),
              icon: const Icon(Icons.folder_open_rounded),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                    child: AppSearchBar(
                      controller: _search,
                      hint: 'Cari obrolan lama',
                      onSubmitted: (_) => _refresh(),
                      onClear: _refresh,
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
                SliverToBoxAdapter(
                  child: _sectionHeader(state.sessions.length),
                ),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
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
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFECEE), Color(0xFFFFF8F2)],
          ),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 132, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Text(
                      'RUANG CERITA PRIBADI',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cerita saja, mulai dari mana pun.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 18,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RuNa siap mendengarkan, tanpa menghakimi.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: () => _openNewChat(),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Mulai bercerita'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -6,
              bottom: -10,
              width: 150,
              height: 204,
              child: Image.asset(
                'assets/images/mascot/chat-welcome.webp',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Pilih topik pembuka',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              Text(
                'Geser untuk melihat',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: kChatSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = kChatSuggestions[i];
              return _chip(s);
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _chip(String text) {
    return SizedBox(
      width: 248,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => _openNewChat(prompt: text),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.forum_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Riwayat obrolan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.foreground,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.red50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.red700,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 19, 22, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6F4), Colors.white],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: Image.asset(
                'assets/images/mascot/chat-welcome.webp',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Belum ada obrolan',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai dari hal yang paling ingin kamu ceritakan hari ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 13),
            OutlinedButton.icon(
              onPressed: () => _openNewChat(),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
              label: const Text('Mulai obrolan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.24),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(ChatSessionListItem session) {
    final dateStr = DateFormat('dd MMM yyyy').format(session.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    color: AppColors.primary,
                    size: 21,
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
                          fontWeight: FontWeight.w800,
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
                  tooltip: 'Opsi obrolan',
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.mutedForeground,
                  ),
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
          builder: (dialogContext) => AppAlertDialog(
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
        builder: (dialogContext) => AppAlertDialog(
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
      builder: (dialogContext) => AppAlertDialog(
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
