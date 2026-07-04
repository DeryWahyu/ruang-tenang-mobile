import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journal.dart';
import '../../common/widgets/mood_emoji.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class JournalCreateScreen extends StatefulWidget {
  final String? uuid; // If null, creates new. If provided, edits existing.
  final Journal? journal; // Optional initial data

  const JournalCreateScreen({super.key, this.uuid, this.journal});

  @override
  State<JournalCreateScreen> createState() => _JournalCreateScreenState();
}

class _JournalCreateScreenState extends State<JournalCreateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  int? _selectedMoodId;
  bool _isPrivate = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal?.title ?? '');
    _contentController = TextEditingController(text: widget.journal?.content ?? '');
    _tagsController = TextEditingController(text: widget.journal?.tags.join(', ') ?? '');
    _selectedMoodId = widget.journal?.moodId;
    _isPrivate = widget.journal?.isPrivate ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tagsStr = _tagsController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jurnal tidak boleh kosong')),
      );
      return;
    }

    final tags = tagsStr.isEmpty
        ? <String>[]
        : tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (widget.uuid == null) {
      context.read<JournalBloc>().add(
            JournalCreateRequested(
              title: title,
              content: content,
              moodId: _selectedMoodId,
              tags: tags,
              isPrivate: _isPrivate,
            ),
          );
    } else {
      context.read<JournalBloc>().add(
            JournalUpdateRequested(
              uuid: widget.uuid!,
              title: title,
              content: content,
              moodId: _selectedMoodId,
              tags: tags,
              isPrivate: _isPrivate,
            ),
          );
    }
  }

  void _showMoodPicker() {
    // Defer to after the current frame to avoid MouseTracker reentrancy on
    // desktop/web (showing a modal synchronously inside the tap event).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('Pilih Suasana Hati',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Bagaimana perasaan Anda saat menulis ini?',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: List.generate(8, (index) {
                    final moodId = index + 1;
                    return MoodEmoji(
                      moodIndex: moodId,
                      size: 44,
                      showLabel: true,
                      isSelected: _selectedMoodId == moodId,
                      onTap: () {
                        setState(() {
                          _selectedMoodId = _selectedMoodId == moodId ? null : moodId;
                        });
                        Navigator.pop(sheetContext);
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JournalBloc, JournalState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == JournalStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.uuid == null ? 'Jurnal berhasil disimpan' : 'Jurnal berhasil diperbarui',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        } else if (state.status == JournalStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.foreground),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<JournalBloc, JournalState>(
                builder: (context, state) {
                  final isLoading = state.status == JournalStatus.loading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            widget.uuid == null ? 'Simpan' : 'Perbarui',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Meta bar (Tags & Mood)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: 'Tambah tag (pisahkan dengan koma)',
                        hintStyle: TextStyle(color: AppColors.mutedForeground.withValues(alpha: 0.5), fontSize: 13),
                        border: InputBorder.none,
                        icon: Icon(Icons.sell_rounded, size: 18, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
                      ),
                      style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showMoodPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedMoodId != null ? AppColors.card : AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedMoodId != null ? AppColors.border : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedMoodId != null)
                              MoodEmoji(moodIndex: _selectedMoodId!, size: 20)
                            else
                              const Icon(Icons.mood_rounded, size: 18, color: AppColors.mutedForeground),
                            const SizedBox(width: 8),
                            Text(
                              _selectedMoodId != null ? 'Mood' : 'Pilih Mood',
                              style: TextStyle(
                                color: _selectedMoodId != null ? AppColors.foreground : AppColors.mutedForeground,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Privacy selector (private vs public/community)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      _isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded,
                      size: 18,
                      color: _isPrivate ? AppColors.mutedForeground : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPrivate ? 'Privat' : 'Publik (Komunitas)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                          Text(
                            _isPrivate
                                ? 'Hanya kamu yang bisa membaca jurnal ini.'
                                : 'Dibagikan ke komunitas setelah lolos moderasi otomatis.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: !_isPrivate,
                      activeThumbColor: AppColors.primary,
                      onChanged: (makePublic) {
                        setState(() => _isPrivate = !makePublic);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul Jurnal...',
                          hintStyle: TextStyle(
                            color: AppColors.mutedForeground.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: AppColors.foreground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Apa yang sedang Anda pikirkan atau rasakan hari ini?',
                          hintStyle: TextStyle(
                            color: AppColors.mutedForeground.withValues(alpha: 0.6),
                            height: 1.8,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 100), // Scrolling padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
