import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../widgets/journal_card.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Defer to after first frame so BlocProvider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalBloc>().add(const JournalListRequested());
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jurnal'),
        centerTitle: false,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: 'Statistik Mood',
            onPressed: () => context.push('/mood/stats'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/journal/create');
          if (mounted) {
            context.read<JournalBloc>().add(const JournalListRequested(refresh: true));
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: AppDimensions.elevationMd,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingBase,
        0,
        AppDimensions.spacingBase,
        AppDimensions.spacingBase,
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSubmitSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari jurnal...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedForeground),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.mutedForeground),
                  onPressed: _onClearSearch,
                )
              : null,
          filled: true,
          fillColor: AppColors.muted,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<JournalBloc, JournalState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.status != JournalStatus.loadMore) {
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

        // First load
        if (state.isLoading && state.items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spacingBase),
            children: List.generate(5, (_) => const JournalCardSkeleton()),
          );
        }

        // Empty
        if (state.items.isEmpty &&
            (state.status == JournalStatus.listSuccess || state.status == JournalStatus.initial)) {
          return AppEmptyState(
            icon: Icons.menu_book_rounded,
            title: state.isSearching ? 'Tidak ada hasil' : 'Belum ada jurnal',
            subtitle: state.isSearching
                ? 'Coba kata kunci lain.'
                : 'Mulai tulis cerita dan pikiranmu hari ini.',
            actionLabel: state.isSearching ? null : 'Tulis Jurnal',
            onAction: state.isSearching ? null : () => context.push('/journal/create'),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<JournalBloc>().add(const JournalListRequested(refresh: true));
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.spacingBase),
            itemCount: state.items.length + (state.hasNextPage && !state.isSearching ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingBase),
                  child: Center(child: AppLoadingIndicator(size: 24)),
                );
              }
              final journal = state.items[index];
              return JournalCard(
                journal: journal,
                onTap: () async {
                  await context.push('/journal/${journal.uuid}');
                  if (mounted) {
                    // Refresh to reflect any edits / deletes.
                    context.read<JournalBloc>().add(const JournalListRequested(refresh: true));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
