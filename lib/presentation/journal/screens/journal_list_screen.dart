import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../widgets/journal_card.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/journal_repository.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterTagsController = TextEditingController();
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _isSearching = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAccess();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalBloc>().add(const JournalListRequested());
    });
  }

  Future<void> _loadAccess() async {
    try {
      final settings = await sl<JournalRepository>().getSettings();
      if (mounted) setState(() => _isBlocked = settings['is_blocked'] == true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _filterTagsController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      context.read<JournalBloc>().add(const JournalLoadMoreRequested());
    }
  }

  void _onSubmitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() => _isSearching = true);
    context.read<JournalBloc>().add(JournalSearchRequested(trimmed));
  }

  void _onClearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<JournalBloc>().add(const JournalSearchCleared());
  }

  Future<void> _openFilters() async {
    DateTime? start = _filterStartDate;
    DateTime? end = _filterEndDate;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter jurnal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _filterTagsController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  hintText: 'Pisahkan dengan koma',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: sheetContext,
                    initialDate: start ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) updateSheet(() => start = date);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Dari tanggal: ${_dateLabel(start)}'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: sheetContext,
                    initialDate: end ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) updateSheet(() => end = date);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Sampai tanggal: ${_dateLabel(end)}'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _filterTagsController.clear();
                        setState(() {
                          _filterStartDate = null;
                          _filterEndDate = null;
                        });
                        context.read<JournalBloc>().add(
                          const JournalListRequested(
                            refresh: true,
                            resetFilters: true,
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (start != null &&
                            end != null &&
                            start!.isAfter(end!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tanggal awal harus sebelum tanggal akhir',
                              ),
                            ),
                          );
                          return;
                        }
                        final tags = _filterTagsController.text
                            .split(',')
                            .map((tag) => tag.trim())
                            .where((tag) => tag.isNotEmpty)
                            .toList();
                        setState(() {
                          _filterStartDate = start;
                          _filterEndDate = end;
                        });
                        context.read<JournalBloc>().add(
                          JournalListRequested(
                            refresh: true,
                            resetFilters: true,
                            tags: tags,
                            startDate: start,
                            endDate: end,
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime? date) =>
      date == null ? 'Semua' : '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBlocked
            ? null
            : () async {
                final bloc = context.read<JournalBloc>();
                await context.push('/journal/create');
                bloc.add(const JournalListRequested(refresh: true));
              },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.edit_document),
        label: const Text(
          'Tulis Jurnal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_isBlocked)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Akses menulis jurnal sedang diblokir untuk akun ini.',
                ),
              ),
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jurnal Pribadi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catat setiap perasaan & momen berharga',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.primary,
              ),
              tooltip: 'Statistik Mood',
              onPressed: () => context.push('/mood/stats'),
            ),
          ),
          IconButton(
            tooltip: 'Analitik dan privasi jurnal',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/journal/insights'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSubmitSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari kenangan atau catatan...',
                  hintStyle: TextStyle(
                    color: AppColors.mutedForeground.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.mutedForeground,
                          ),
                          onPressed: _onClearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Filter jurnal',
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<JournalBloc, JournalState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status != JournalStatus.loadMore) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == JournalStatus.failure && state.items.isEmpty) {
          return AppErrorWidget(
            message: state.errorMessage ?? 'Gagal memuat jurnal',
            onRetry: () => context.read<JournalBloc>().add(
              const JournalListRequested(refresh: true),
            ),
          );
        }

        if (state.isLoading && state.items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: List.generate(4, (_) => const JournalCardSkeleton()),
          );
        }

        if (state.items.isEmpty &&
            (state.status == JournalStatus.listSuccess ||
                state.status == JournalStatus.initial)) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: AppEmptyState(
              icon: Icons.menu_book_rounded,
              title: state.isSearching ? 'Tidak ada hasil' : 'Mulai Menulis',
              subtitle: state.isSearching
                  ? 'Coba gunakan kata kunci lain.'
                  : 'Setiap pikiran dan cerita Anda berharga. Mulai catat sekarang.',
              actionLabel: state.isSearching ? null : 'Tulis Jurnal Pertama',
              onAction: state.isSearching
                  ? null
                  : () async {
                      final bloc = context.read<JournalBloc>();
                      await context.push('/journal/create');
                      bloc.add(const JournalListRequested(refresh: true));
                    },
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            context.read<JournalBloc>().add(
              const JournalListRequested(refresh: true),
            );
          },
          child: ListView.builder(
            controller: _scrollController,
            cacheExtent: 600,
            padding: const EdgeInsets.all(20),
            itemCount:
                state.items.length +
                (state.hasNextPage && !state.isSearching ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: AppLoadingIndicator(size: 24)),
                );
              }
              final journal = state.items[index];
              return JournalCard(
                journal: journal,
                onTap: () async {
                  final bloc = context.read<JournalBloc>();
                  await context.push('/journal/${journal.uuid}');
                  bloc.add(const JournalListRequested(refresh: true));
                },
              );
            },
          ),
        );
      },
    );
  }
}
