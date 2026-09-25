import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/story.dart';
import '../../../domain/repositories/story_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../common/widgets/app_alert_dialog.dart';
import '../../common/widgets/mascot_hero.dart';

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});
  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  final _repository = sl<StoryRepository>();
  List<StoryCard> _stories = [];
  String? _status;
  String? _error;
  bool _loading = true;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (!_hasMore || _loading)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = more ? _page + 1 : 1;
      final items = await _repository.getMyStories(page: page, status: _status);
      if (!mounted) return;
      setState(() {
        _stories = [...(more ? _stories : <StoryCard>[]), ...items];
        _page = page;
        _hasMore = items.length == 10;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Kisahmu belum berhasil dimuat.';
        });
      }
    }
  }

  Future<void> _delete(StoryCard story) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: const Text('Hapus kisah?'),
        content: Text(story.title),
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
      await _repository.deleteStory(story.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kisah belum berhasil dihapus.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MascotHero(
          title: 'Kisah Saya',
          description:
              'Bagikan perjalananmu. Kisah baru akan melewati moderasi.',
          pose: 'community',
          action: FilledButton.icon(
            onPressed: () => context.push('/stories/new').then((_) => _load()),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Tulis kisah'),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _status ?? 'all',
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Semua')),
            DropdownMenuItem(
              value: 'pending',
              child: Text('Menunggu moderasi'),
            ),
            DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
            DropdownMenuItem(
              value: 'revision_requested',
              child: Text('Perlu revisi'),
            ),
            DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
          ],
          onChanged: (value) {
            setState(() => _status = value == 'all' ? null : value);
            _load();
          },
        ),
        if (_loading && _stories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error != null)
          ListTile(
            title: Text(_error!),
            trailing: TextButton(
              onPressed: _load,
              child: const Text('Coba lagi'),
            ),
          ),
        if (!_loading && _stories.isEmpty && _error == null)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'Kamu belum menulis kisah.',
              textAlign: TextAlign.center,
            ),
          ),
        ..._stories.map(
          (story) => Card(
            child: ListTile(
              title: Text(story.title),
              subtitle: Text(story.status),
              onTap: () => context.push('/stories/${story.id}'),
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    context
                        .push('/stories/edit/${story.id}')
                        .then((_) => _load());
                  }
                  if (action == 'delete') _delete(story);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          ),
        ),
        if (_hasMore && _stories.isNotEmpty)
          TextButton(
            onPressed: _loading ? null : () => _load(more: true),
            child: Text(_loading ? 'Memuat...' : 'Muat lagi'),
          ),
      ],
    ),
  );
}

class StoryEditorScreen extends StatefulWidget {
  final String? id;
  const StoryEditorScreen({super.key, this.id});
  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final _repository = sl<StoryRepository>();
  final _uploads = sl<UploadRepository>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _warning = TextEditingController();
  final _tag = TextEditingController();
  List<StoryCategory> _categories = [];
  final Set<String> _selected = {};
  final List<String> _tags = [];
  String? _cover;
  bool _anonymous = false;
  bool _hasWarning = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _warning.dispose();
    _tag.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final categories = await _repository.getCategories();
      final story = widget.id == null
          ? null
          : await _repository.getStory(widget.id!);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _title.text = story?.title ?? '';
        _content.text = story?.content ?? '';
        _warning.text = story?.triggerWarningText ?? '';
        _selected.addAll(
          story?.categories.map((category) => category.id) ?? <String>[],
        );
        _tags.addAll(story?.tags ?? []);
        _cover = story?.coverImage;
        _anonymous = story?.isAnonymous ?? false;
        _hasWarning = story?.hasTriggerWarning ?? false;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Editor kisah belum berhasil dimuat.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      final url = await _uploads.uploadImage(File(picked.path));
      if (mounted) setState(() => _cover = url);
    } catch (_) {
      if (mounted) setState(() => _error = 'Sampul belum berhasil diunggah.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTag() {
    final tag = _tag.text.trim().toLowerCase();
    if (tag.isEmpty || _tags.contains(tag) || _tags.length >= 5) return;
    setState(() {
      _tags.add(tag);
      _tag.clear();
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().length < 5 ||
        _title.text.trim().length > 200 ||
        _content.text.trim().length < 200 ||
        _selected.isEmpty ||
        (_hasWarning && _warning.text.trim().isEmpty)) {
      setState(
        () => _error =
            'Isi judul 5–200 karakter, kisah minimal 200 karakter, pilih kategori, dan lengkapi peringatan konten.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final story = await _repository.saveStory(
        id: widget.id,
        data: {
          'title': _title.text.trim(),
          'content': _content.text.trim(),
          'category_ids': _selected.toList(),
          'cover_image': _cover ?? '',
          'tags': _tags,
          'is_anonymous': _anonymous,
          'has_trigger_warning': _hasWarning,
          'trigger_warning_text': _hasWarning ? _warning.text.trim() : '',
        },
      );
      if (mounted) context.go('/stories/${story.id}');
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Kisah belum berhasil dikirim. Periksa isi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.id == null ? 'Tulis kisah' : 'Edit kisah'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const MascotHero(
                title: 'Cerita yang berarti',
                description:
                    'Kisahmu dapat membantu sahabat lain merasa ditemani.',
                pose: 'community',
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _title,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Judul kisah'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickCover,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _cover == null || _cover!.isEmpty
                      ? 'Pilih sampul'
                      : 'Ganti sampul',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Kategori (pilih 1–3)'),
              Wrap(
                spacing: 8,
                children: _categories
                    .map(
                      (category) => FilterChip(
                        label: Text(category.name),
                        selected: _selected.contains(category.id),
                        onSelected: (selected) => setState(() {
                          if (selected && _selected.length < 3) {
                            _selected.add(category.id);
                          } else if (!selected) {
                            _selected.remove(category.id);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                minLines: 10,
                maxLines: null,
                maxLength: 50000,
                decoration: const InputDecoration(
                  labelText: 'Isi kisah (minimal 200 karakter)',
                  alignLabelWithHint: true,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tag,
                      decoration: const InputDecoration(labelText: 'Tag'),
                    ),
                  ),
                  IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
                ],
              ),
              Wrap(
                spacing: 6,
                children: _tags
                    .map(
                      (tag) => InputChip(
                        label: Text('#$tag'),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      ),
                    )
                    .toList(),
              ),
              SwitchListTile(
                value: _anonymous,
                onChanged: (value) => setState(() => _anonymous = value),
                title: const Text('Posting anonim'),
              ),
              SwitchListTile(
                value: _hasWarning,
                onChanged: (value) => setState(() => _hasWarning = value),
                title: const Text('Peringatan konten'),
              ),
              if (_hasWarning)
                TextField(
                  controller: _warning,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Jelaskan pemicu yang mungkin ada',
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Mengirim...' : 'Kirim kisah'),
              ),
            ],
          ),
  );
}
