import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/mascot_hero.dart';
import '../../common/widgets/app_search_bar.dart';
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
    context.read<JournalBloc>().add(JournalSearchRequested(trimmed));
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<JournalBloc>().add(const JournalSearchCleared());
  }

  Future<void> _openFilters() async {
    DateTime? start = _filterStartDate;
    DateTime? end = _filterEndDate;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateSheet) {
          Future<void> pickDate({required bool isStart}) async {
            final selected = await showDatePicker(
              context: sheetContext,
              initialDate: (isStart ? start : end) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (selected != null) {
              updateSheet(() {
                if (isStart) {
                  start = selected;
                } else {
                  end = selected;
                }
              });
            }
          }

          Widget dateCard({
            required String label,
            required DateTime? date,
            required VoidCallback onTap,
          }) => Expanded(
            child: Material(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 76),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date == null ? 'Semua tanggal' : _dateLabel(date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.filter_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter jurnal',
                              style: TextStyle(
                                color: AppColors.foreground,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Temukan catatan berdasarkan tag dan tanggal.',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _filterTagsController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Pisahkan tag dengan koma',
                      prefixIcon: const Icon(Icons.sell_outlined, size: 19),
                      filled: true,
                      fillColor: AppColors.gray50,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      dateCard(
                        label: 'DARI TANGGAL',
                        date: start,
                        onTap: () => pickDate(isStart: true),
                      ),
                      const SizedBox(width: 10),
                      dateCard(
                        label: 'SAMPAI TANGGAL',
                        date: end,
                        onTap: () => pickDate(isStart: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text('Reset filter'),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dateLabel(DateTime? date) =>
      date == null ? 'Semua' : '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            _buildWriteJournalButton(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteJournalButton() {
    final VoidCallback? onPressed = _isBlocked
        ? null
        : () async {
            final bloc = context.read<JournalBloc>();
            await context.push('/journal/create');
            bloc.add(const JournalListRequested(refresh: true));
          };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isBlocked
                          ? [AppColors.gray50, AppColors.gray100]
                          : const [Color(0xFFFFF7E8), Color(0xFFFFF0E7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _isBlocked
                          ? AppColors.border
                          : const Color(0xFFF5DCA8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD88936).withValues(alpha: 0.09),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 90, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isBlocked
                                      ? 'JURNAL PRIBADI'
                                      : 'RUANG MENULISMU',
                                  style: TextStyle(
                                    color: _isBlocked
                                        ? AppColors.gray500
                                        : AppColors.accentOrangeDark,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Tulis Jurnal',
                                  style: TextStyle(
                                    color: _isBlocked
                                        ? AppColors.gray500
                                        : AppColors.foreground,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  _isBlocked
                                      ? 'Akses menulis sedang dibatasi'
                                      : 'Catat ceritamu hari ini',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _isBlocked
                                  ? AppColors.gray200
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: _isBlocked
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 9,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              _isBlocked
                                  ? Icons.lock_outline_rounded
                                  : Icons.arrow_forward_rounded,
                              color: _isBlocked
                                  ? AppColors.gray500
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -6,
              top: -17,
              width: 94,
              height: 106,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: 8,
                      top: 19,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE2A7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/mascot/tour-journal.webp',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          const MascotHero(
            title: 'Jurnal Pribadi',
            description: 'Catat perasaan dan momen berharga dengan nyaman.',
            pose: 'journal',
            overflowMascot: true,
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => context.push('/journal/insights'),
                borderRadius: BorderRadius.circular(17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Wawasan jurnal',
                              style: TextStyle(
                                color: AppColors.foreground,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Kenali pola dari ceritamu',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Cari kenangan atau catatan...',
              onSubmitted: _onSubmitSearch,
              onClear: _onClearSearch,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Filter jurnal',
            onPressed: _openFilters,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            padding: EdgeInsets.zero,
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
