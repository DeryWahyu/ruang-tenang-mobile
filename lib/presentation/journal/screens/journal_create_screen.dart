import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/journal.dart';
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
  String _selectedMoodEmoji = '';
  
  final List<String> _moodOptions = ['??', '??', '??', '??', '??', '??', '??', '??', '??', '??'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal?.title ?? '');
    _contentController = TextEditingController(text: widget.journal?.content ?? '');
    _tagsController = TextEditingController(text: widget.journal?.tags.join(', ') ?? '');
    _selectedMoodEmoji = widget.journal?.moodEmoji ?? '';
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
              
              tags: tags,
            ),
          );
    } else {
      context.read<JournalBloc>().add(
            JournalUpdateRequested(
              uuid: widget.uuid!,
              title: title,
              content: content,
              
              tags: tags,
            ),
          );
    }
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Suasana Hati',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bagaimana perasaan Anda saat menulis ini?',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _moodOptions.map((emoji) {
                  final isSelected = _selectedMoodEmoji == emoji;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMoodEmoji = isSelected ? '' : emoji;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
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
          context.pop();
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.foreground),
            onPressed: () => context.pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: BlocBuilder<JournalBloc, JournalState>(
                builder: (context, state) {
                  final isLoading = state.status == JournalStatus.loading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          hintText: 'Tambah tag (pisahkan dengan koma)',
                          hintStyle: TextStyle(color: AppColors.mutedForeground.withOpacity(0.5), fontSize: 13),
                          border: InputBorder.none,
                          icon: Icon(Icons.sell_rounded, size: 18, color: AppColors.mutedForeground.withOpacity(0.5)),
                        ),
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showMoodPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedMoodEmoji.isNotEmpty 
                              ? AppColors.card 
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedMoodEmoji.isNotEmpty 
                                ? AppColors.border 
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMoodEmoji.isNotEmpty ? _selectedMoodEmoji : '??',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedMoodEmoji.isNotEmpty ? 'Mood' : 'Pilih Mood',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _selectedMoodEmoji.isNotEmpty ? AppColors.foreground : AppColors.mutedForeground,
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
              
              // Editor Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul Jurnal...',
                          hintStyle: TextStyle(
                            color: AppColors.mutedForeground.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
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
                            color: AppColors.mutedForeground.withOpacity(0.6),
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
