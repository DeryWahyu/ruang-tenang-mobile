import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/repositories/article_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../common/widgets/app_alert_dialog.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/mascot_hero.dart';

class MyArticlesState {
  final List<ArticleListItem> items;
  final List<ArticleCategory> categories;
  final Article? editing;
  final bool loading;
  final bool saving;
  final bool saved;
  final String? error;
  final int page;
  final bool hasMore;
  final String? cover;
  const MyArticlesState({
    this.items = const [],
    this.categories = const [],
    this.editing,
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.error,
    this.page = 0,
    this.hasMore = true,
    this.cover,
  });
}

class MyArticlesCubit extends Cubit<MyArticlesState> {
  final ArticleRepository _articles;
  final UploadRepository _uploads;
  MyArticlesCubit(this._articles, this._uploads)
    : super(const MyArticlesState());

  Future<void> load({bool more = false, String? search}) async {
    if (state.loading || (more && !state.hasMore)) return;
    final page = more ? state.page + 1 : 1;
    emit(
      MyArticlesState(
        items: state.items,
        loading: true,
        page: state.page,
        hasMore: state.hasMore,
      ),
    );
    try {
      final items = await _articles.getMyArticles(page: page, search: search);
      emit(
        MyArticlesState(
          items: [...(more ? state.items : <ArticleListItem>[]), ...items],
          page: page,
          hasMore: items.length == 10,
        ),
      );
    } catch (_) {
      emit(
        MyArticlesState(
          items: state.items,
          page: state.page,
          error: 'Artikelmu belum berhasil dimuat.',
        ),
      );
    }
  }

  Future<void> loadEditor(String? id) async {
    emit(const MyArticlesState(loading: true));
    try {
      final categories = await _articles.getCategories();
      final article = id == null ? null : await _articles.getMyArticle(id);
      emit(
        MyArticlesState(
          categories: categories,
          editing: article,
          cover: article?.thumbnail,
        ),
      );
    } catch (_) {
      emit(
        const MyArticlesState(error: 'Editor artikel belum berhasil dimuat.'),
      );
    }
  }

  Future<void> uploadCover(File file) async {
    emit(
      MyArticlesState(
        categories: state.categories,
        editing: state.editing,
        saving: true,
        cover: state.cover,
      ),
    );
    try {
      final cover = await _uploads.uploadImage(file);
      emit(
        MyArticlesState(
          categories: state.categories,
          editing: state.editing,
          cover: cover,
        ),
      );
    } catch (_) {
      emit(
        MyArticlesState(
          categories: state.categories,
          editing: state.editing,
          error: 'Sampul belum berhasil diunggah.',
          cover: state.cover,
        ),
      );
    }
  }

  Future<void> save({
    String? id,
    required String title,
    required String content,
    required int categoryId,
  }) async {
    emit(
      MyArticlesState(
        categories: state.categories,
        editing: state.editing,
        saving: true,
        cover: state.cover,
      ),
    );
    try {
      await _articles.saveMyArticle(
        id: id,
        title: title,
        content: content,
        categoryId: categoryId,
        thumbnail: state.cover,
      );
      emit(
        MyArticlesState(
          categories: state.categories,
          saved: true,
          cover: state.cover,
        ),
      );
    } catch (_) {
      emit(
        MyArticlesState(
          categories: state.categories,
          editing: state.editing,
          error: 'Artikel belum berhasil disimpan.',
          cover: state.cover,
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _articles.deleteMyArticle(id);
      emit(
        MyArticlesState(
          items: state.items.where((item) => item.slug != id).toList(),
          page: state.page,
          hasMore: state.hasMore,
        ),
      );
    } catch (_) {
      emit(
        MyArticlesState(
          items: state.items,
          page: state.page,
          error: 'Artikel belum berhasil dihapus.',
        ),
      );
    }
  }
}

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});
  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  late final MyArticlesCubit _cubit = sl<MyArticlesCubit>()..load();
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: Scaffold(
      body: BlocBuilder<MyArticlesCubit, MyArticlesState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MascotHero(
              title: 'Artikel Saya',
              description:
                  'Tulisanmu dapat menemani orang lain setelah melalui moderasi.',
              pose: 'read',
              action: FilledButton.icon(
                onPressed: () =>
                    context.push('/articles/new').then((_) => _cubit.load()),
                icon: const Icon(Icons.add),
                label: const Text('Tulis artikel'),
              ),
            ),
            const SizedBox(height: 16),
            AppSearchBar(
              controller: _search,
              hint: 'Cari artikel saya',
              onSubmitted: (value) => _cubit.load(search: value),
              onClear: () => _cubit.load(),
            ),
            if (state.loading && state.items.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (state.error != null) ...[
              Text(state.error!),
              TextButton(
                onPressed: () => _cubit.load(search: _search.text),
                child: const Text('Coba lagi'),
              ),
            ],
            if (!state.loading && state.items.isEmpty && state.error == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Kamu belum menulis artikel.',
                  textAlign: TextAlign.center,
                ),
              ),
            ...state.items.map(
              (article) => Card(
                child: ListTile(
                  title: Text(article.title),
                  subtitle: Text(
                    article.moderationStatus.isEmpty
                        ? article.status
                        : article.moderationStatus,
                  ),
                  onTap: () => context
                      .push('/articles/edit/${article.slug}')
                      .then((_) => _cubit.load()),
                  trailing: article.status == 'blocked'
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              context
                                  .push('/articles/edit/${article.slug}')
                                  .then((_) => _cubit.load());
                              return;
                            }
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AppAlertDialog(
                                title: const Text('Hapus artikel?'),
                                content: Text(article.title),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) _cubit.delete(article.slug);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (state.hasMore && state.items.isNotEmpty)
              TextButton(
                onPressed: state.loading
                    ? null
                    : () => _cubit.load(more: true, search: _search.text),
                child: Text(state.loading ? 'Memuat...' : 'Muat lagi'),
              ),
          ],
        ),
      ),
    ),
  );
}

class ArticleEditorScreen extends StatefulWidget {
  final String? id;
  const ArticleEditorScreen({super.key, this.id});
  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  late final MyArticlesCubit _cubit = sl<MyArticlesCubit>()
    ..loadEditor(widget.id);
  final _title = TextEditingController();
  final _content = TextEditingController();
  int? _categoryId;
  bool _initialized = false;
  bool _preview = false;

  void _format(String before, String after) {
    final selection = _content.selection;
    final start = selection.isValid ? selection.start : _content.text.length;
    final end = selection.isValid ? selection.end : start;
    final selected = _content.text.substring(start, end);
    final replacement = '$before$selected$after';
    _content.value = TextEditingValue(
      text: _content.text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + before.length + selected.length,
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocConsumer<MyArticlesCubit, MyArticlesState>(
      listener: (context, state) {
        if (state.saved) context.pop();
      },
      builder: (context, state) {
        if (state.loading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!_initialized && state.categories.isNotEmpty) {
          _initialized = true;
          _title.text = state.editing?.title ?? '';
          _content.text = state.editing?.content ?? '';
          _categoryId = state.editing?.categoryId ?? state.categories.first.id;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.id == null ? 'Tulis artikel' : 'Edit artikel'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const MascotHero(
                title: 'Tulisanmu berarti',
                description:
                    'Bagikan pengalaman atau pengetahuan untuk sahabat lain.',
                pose: 'read',
              ),
              const SizedBox(height: 16),
              if (state.error != null)
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Judul artikel'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: state.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.saving
                    ? null
                    : () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (picked != null) {
                          _cubit.uploadCover(File(picked.path));
                        }
                      },
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  state.cover == null ? 'Pilih sampul' : 'Ganti sampul',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Text('Isi artikel')),
                  TextButton.icon(
                    onPressed: () => setState(() => _preview = !_preview),
                    icon: Icon(_preview ? Icons.edit : Icons.visibility),
                    label: Text(_preview ? 'Edit' : 'Pratinjau'),
                  ),
                ],
              ),
              if (!_preview) ...[
                Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Tebal',
                      onPressed: () => _format('<strong>', '</strong>'),
                      icon: const Icon(Icons.format_bold),
                    ),
                    IconButton(
                      tooltip: 'Miring',
                      onPressed: () => _format('<em>', '</em>'),
                      icon: const Icon(Icons.format_italic),
                    ),
                    IconButton(
                      tooltip: 'Subjudul',
                      onPressed: () => _format('<h2>', '</h2>'),
                      icon: const Icon(Icons.title),
                    ),
                    IconButton(
                      tooltip: 'Daftar',
                      onPressed: () => _format('<ul><li>', '</li></ul>'),
                      icon: const Icon(Icons.format_list_bulleted),
                    ),
                  ],
                ),
                TextField(
                  controller: _content,
                  minLines: 10,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Tulis isi dan gunakan tombol format',
                    alignLabelWithHint: true,
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Html(data: _content.text),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed:
                    state.saving ||
                        _categoryId == null ||
                        state.editing?.status == 'blocked'
                    ? null
                    : () {
                        if (_title.text.trim().isEmpty ||
                            _content.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Judul dan isi artikel wajib diisi',
                              ),
                            ),
                          );
                          return;
                        }
                        _cubit.save(
                          id: widget.id,
                          title: _title.text.trim(),
                          content: _content.text.trim(),
                          categoryId: _categoryId!,
                        );
                      },
                child: Text(state.saving ? 'Menyimpan...' : 'Simpan artikel'),
              ),
            ],
          ),
        );
      },
    ),
  );
}
