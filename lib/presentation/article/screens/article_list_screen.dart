import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/app_environment.dart';
import '../../../domain/entities/article.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticleBloc>()
        ..add(const ArticleListRequested())
        ..add(const ArticleCategoriesRequested()),
      child: const _ArticleListView(),
    );
  }
}

class _ArticleListView extends StatelessWidget {
  const _ArticleListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel & Bacaan'),
        centerTitle: true,
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.categories.isNotEmpty) _buildCategoryChips(context, state),
              Expanded(
                child: state.status == ArticleStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.status == ArticleStatus.failure
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: AppColors.mutedForeground),
                                const SizedBox(height: 16),
                                Text(state.errorMessage, textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<ArticleBloc>().add(const ArticleListRequested(refresh: true)),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : state.items.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.article_outlined, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
                                    const SizedBox(height: 16),
                                    const Text('Belum ada artikel', style: TextStyle(color: AppColors.mutedForeground)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async => context.read<ArticleBloc>().add(const ArticleListRequested(refresh: true)),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: state.items.length,
                                  itemBuilder: (context, index) => _buildArticleCard(context, state.items[index]),
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, ArticleState state) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: state.selectedCategoryId == null,
            onSelected: (_) => context.read<ArticleBloc>().add(const ArticleCategorySelected(null)),
            selectedColor: AppColors.red100,
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          ...state.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.name),
                  selected: state.selectedCategoryId == cat.id,
                  onSelected: (_) => context.read<ArticleBloc>().add(ArticleCategorySelected(cat.id)),
                  selectedColor: AppColors.red100,
                  checkmarkColor: AppColors.primary,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleListItem article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/articles/${article.slug}'),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: article.thumbnail.isNotEmpty
                  ? Image.network(
                      article.thumbnail.startsWith('http') ? article.thumbnail : '${AppEnvironment.baseUrl}/${article.thumbnail}',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 110,
                        height: 110,
                        color: AppColors.muted,
                        child: const Icon(Icons.article, color: AppColors.mutedForeground),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: AppColors.muted,
                      child: const Icon(Icons.article, color: AppColors.mutedForeground),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(article.category!.name, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    Text(article.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(article.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.3)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (article.author != null) ...[
                          Text(article.author!.name, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: AppColors.mutedForeground)),
                          const SizedBox(width: 6),
                        ],
                        Text(_formatDate(article.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
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

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays < 1) return 'Hari ini';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}