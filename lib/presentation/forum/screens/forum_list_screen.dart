import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/app_skeleton.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../../domain/entities/forum.dart';
import '../../common/widgets/app_avatar.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../../auth/bloc/auth_bloc.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForumBloc>()
        ..add(const ForumListRequested())
        ..add(const ForumCategoriesRequested()),
      child: const _ForumListView(),
    );
  }
}

class _ForumListView extends StatefulWidget {
  const _ForumListView();

  @override
  State<_ForumListView> createState() => _ForumListViewState();
}

class _ForumListViewState extends State<_ForumListView> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedCategoryId;
  String? _selectedCircle;

  static const _circles = <String, String>{
    'tekanan_akademik': 'Tekanan akademik',
    'relasi_pertemanan': 'Relasi & pertemanan',
    'regulasi_emosi': 'Regulasi emosi',
    'pemulihan_burnout': 'Pemulihan burnout',
  };
  static const _formats = <String, String>{
    'curhat': 'Curhat',
    'minta_saran': 'Minta saran',
    'cari_teman': 'Cari teman seperjuangan',
    'victory_note': 'Victory Note',
    'confession': 'Confessional Writing',
  };
  static const _formatDescriptions = <String, String>{
    'curhat': 'Ruang aman untuk menulis isi hati dengan jujur dan tenang.',
    'minta_saran': 'Minta masukan konkret untuk situasi yang sedang dihadapi.',
    'cari_teman': 'Cari teman seperjalanan yang mengalami hal serupa.',
    'victory_note': 'Rayakan kemajuan kecil dan bagikan semangat.',
    'confession':
        'Tulisan pengakuan untuk melepaskan beban yang sulit diucapkan.',
  };
  static const _formatStarters = <String, String>{
    'curhat':
        'Aku lagi butuh ruang untuk cerita. Belakangan ini rasanya campur aduk dan aku ingin menuliskannya pelan-pelan.',
    'minta_saran':
        'Aku butuh saran dari teman-teman yang mungkin pernah ada di situasi serupa. Menurut kalian langkah pertama yang paling realistis apa?',
    'cari_teman':
        'Lagi cari teman seperjuangan yang sedang menghadapi hal mirip. Siapa pun yang relate, aku senang kalau kita bisa saling dukung.',
    'victory_note':
        'Mau berbagi kemenangan kecil hari ini: aku berhasil menyelesaikan satu hal yang kemarin terasa berat. Semoga ini jadi semangat bareng.',
    'confession':
        'Aku mau jujur tentang hal yang selama ini kupendam. Menulis ini jadi caraku untuk mulai berdamai.',
  };

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _reload();
    });
  }

  void _reload() {
    context.read<ForumBloc>().add(
      ForumListRequested(
        refresh: true,
        updateFilters: true,
        search: _searchController.text.trim(),
        categoryId: _selectedCategoryId,
        circle: _selectedCircle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocked =
        context.watch<AuthBloc>().state.user?.isForumBlocked == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Forum Komunitas'), centerTitle: true),
      body: Column(
        children: [
          if (blocked)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Akses forum kamu sedang diblokir. Kamu masih bisa membaca topik.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Cari Diskusi...',
              onChanged: _onSearchChanged,
              onClear: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
          BlocBuilder<ForumBloc, ForumState>(
            buildWhen: (previous, current) =>
                previous.categories != current.categories,
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      key: ValueKey('category-${_selectedCategoryId ?? 0}'),
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...state.categories.map(
                          (category) => DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                        _reload();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey('circle-${_selectedCircle ?? 'all'}'),
                      initialValue: _selectedCircle,
                      decoration: const InputDecoration(
                        labelText: 'Lingkar dukungan',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ..._circles.entries.map(
                          (entry) => DropdownMenuItem<String?>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCircle = value);
                        _reload();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<ForumBloc, ForumState>(
              listener: (context, state) {
                if (state.status == ForumStatus.success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.successMessage)));
                  context.read<ForumBloc>().add(
                    const ForumListRequested(refresh: true),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == ForumStatus.loading &&
                    state.threads.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: List.generate(5, (_) => const AppSkeletonCard()),
                  );
                }
                if (state.status == ForumStatus.failure) {
                  return AppErrorWidget(
                    message: state.errorMessage.isNotEmpty
                        ? state.errorMessage
                        : 'Gagal memuat forum',
                    onRetry: () => context.read<ForumBloc>().add(
                      const ForumListRequested(refresh: true),
                    ),
                  );
                }

                if (state.threads.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _reload(),
                    child: LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            height: constraints.maxHeight > 0
                                ? constraints.maxHeight
                                : 400,
                            alignment: Alignment.center,
                            child: AppEmptyState(
                              icon: Icons.forum_outlined,
                              title: 'Belum Ada Diskusi',
                              subtitle:
                                  _searchController.text.isNotEmpty ||
                                      _selectedCategoryId != null ||
                                      _selectedCircle != null
                                  ? 'Coba pencarian atau filter lain.'
                                  : 'Jadilah yang pertama memulai diskusi di komunitas.',
                              actionLabel:
                                  _searchController.text.isNotEmpty ||
                                      _selectedCategoryId != null ||
                                      _selectedCircle != null
                                  ? 'Bersihkan filter'
                                  : null,
                              onAction: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedCategoryId = null;
                                  _selectedCircle = null;
                                });
                                _reload();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    cacheExtent: 600,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.threads.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) =>
                        index == state.threads.length
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Center(
                              child: OutlinedButton(
                                onPressed: state.loadingMore
                                    ? null
                                    : () => context.read<ForumBloc>().add(
                                        const ForumLoadMoreRequested(),
                                      ),
                                child: Text(
                                  state.loadingMore
                                      ? 'Memuat...'
                                      : 'Muat lebih banyak',
                                ),
                              ),
                            ),
                          )
                        : _buildThreadCard(context, state.threads[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: blocked ? null : () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildThreadCard(BuildContext context, ForumThread thread) {
    final authorName = thread.user?.name ?? 'Anonim';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/forum/${thread.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: avatar + author + time + answered badge
                Row(
                  children: [
                    AppAvatar(
                      name: authorName,
                      imageUrl: thread.user?.avatar,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 11,
                                color: AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(thread.createdAt),
                                style: const TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (thread.hasAcceptedAnswer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Terjawab',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Category badge
                if (thread.category != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.red100),
                    ),
                    child: Text(
                      thread.category!.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                // Title + preview
                const SizedBox(height: 10),
                Text(
                  thread.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (thread.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    thread.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],

                // Footer stats
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 17,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${thread.repliesCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'balasan',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Icon(
                        thread.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 17,
                        color: thread.isLiked
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${thread.likesCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'suka',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
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
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    int? categoryId;
    String format = 'curhat';
    final categories = context.read<ForumBloc>().state.categories;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, updateSheet) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Diskusi Baru',
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Umum'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => updateSheet(() => categoryId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Diskusi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Format topik'),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _formats.entries
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(entry.value),
                          selected: format == entry.key,
                          onSelected: (_) => updateSheet(() {
                            format = entry.key;
                            if (contentController.text.trim().isEmpty) {
                              contentController.text =
                                  _formatStarters[format] ?? '';
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatDescriptions[format] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                if (format == 'confession')
                  const Text(
                    'Identitas akun tetap terlihat oleh sistem untuk moderasi.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final content = contentController.text.trim();
                    final prefix = '[Format: ${_formats[format]}]';
                    context.read<ForumBloc>().add(
                      ForumCreateRequested(
                        title: titleController.text.trim(),
                        content: content.isEmpty
                            ? prefix
                            : '$prefix\n\n$content',
                        categoryId: categoryId,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Kirim'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      contentController.dispose();
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 30) return '${diff.inDays} hari lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
