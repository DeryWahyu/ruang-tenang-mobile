import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../common/widgets/app_network_image.dart';
import '../../common/widgets/app_avatar.dart';
import '../../common/widgets/app_error_widget.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String slug;
  const ArticleDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticleBloc>()..add(ArticleDetailRequested(slug)),
      child: _ArticleDetailView(slug: slug),
    );
  }
}

class _ArticleDetailView extends StatelessWidget {
  final String slug;
  const _ArticleDetailView({required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        final article = state.detail;

        return Scaffold(
          appBar: AppBar(
            title: Text(article?.title ?? 'Artikel', maxLines: 1, overflow: TextOverflow.ellipsis),
            centerTitle: true,
          ),
          body: state.status == ArticleStatus.detailLoading
              ? const Center(child: CircularProgressIndicator())
              : state.status == ArticleStatus.failure
                  ? AppErrorWidget(
                      message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Gagal memuat artikel',
                      onRetry: () => context.read<ArticleBloc>().add(ArticleDetailRequested(slug)),
                    )
                  : article == null
                      ? const Center(child: Text('Artikel tidak ditemukan'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article.thumbnail.isNotEmpty)
                                AppNetworkImage(
                                  url: article.thumbnail,
                                  width: double.infinity,
                                  height: 220,
                                  fallbackIcon: Icons.article,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (article.category != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(6)),
                                          child: Text(article.category!.name, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    Text(article.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        AppAvatar(
                                          name: article.author?.name ?? 'Anonim',
                                          imageUrl: article.author?.avatar,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(article.author?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                            Text(_formatDate(article.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 32),
                                    Html(
                                      data: Helpers.stripH2Tags(article.content),
                                      style: {
                                        'body': Style(
                                          fontSize: FontSize(15),
                                          lineHeight: const LineHeight(1.7),
                                          color: AppColors.foreground,
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        'p': Style(margin: Margins.only(bottom: 12)),
                                        'h1': Style(fontSize: FontSize(22), fontWeight: FontWeight.bold),
                                        'h2': Style(fontSize: FontSize(20), fontWeight: FontWeight.bold),
                                        'h3': Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
                                        'strong': Style(fontWeight: FontWeight.bold),
                                        'em': Style(fontStyle: FontStyle.italic),
                                        'a': Style(color: AppColors.primary),
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}