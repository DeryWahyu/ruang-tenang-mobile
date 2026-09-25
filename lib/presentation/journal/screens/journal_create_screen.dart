import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/entities/journal.dart';
import '../../../domain/repositories/journal_repository.dart';
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
  bool _shareWithAI = false;
  bool _journalBlocked = false;
  String _mode = 'structured-reflection';
  String? _writingPrompt;
  bool _promptLoading = false;

  static const _modes = <String, String>{
    'brain-dump': 'Cerita bebas',
    'structured-reflection': 'Refleksi',
    'gratitude': 'Rasa syukur',
    'action-plan': 'Rencana aksi',
  };

  static const _templates = <String, String>{
    'brain-dump': '',
    'structured-reflection':
        'Apa yang terjadi hari ini?\n\nApa yang aku rasakan?\n\nApa yang kubutuhkan sekarang?\n',
    'gratitude':
        'Tiga hal kecil yang kusyukuri hari ini:\n1. \n2. \n3. \n\nPerasaan yang ingin kusimpan:\n',
    'action-plan':
        'Hal yang sedang kuhadapi:\n\nSatu langkah kecil yang bisa kulakukan:\n\nKapan aku akan memulainya?\n',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal?.title ?? '');
    _contentController = TextEditingController(
      text: widget.journal?.content ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.journal?.tags.join(', ') ?? '',
    );
    _selectedMoodId = widget.journal?.moodId;
    _isPrivate = widget.journal?.isPrivate ?? true;
    _shareWithAI = widget.journal?.shareWithAI ?? false;
    _loadDefaultShare();
  }

  Future<void> _loadDefaultShare() async {
    try {
      final settings = await sl<JournalRepository>().getSettings();
      if (mounted) {
        setState(() {
          _journalBlocked = settings['is_blocked'] == true;
          if (widget.journal == null) {
            _shareWithAI = settings['default_share_with_ai'] == true;
          }
        });
      }
    } catch (_) {
      /* Private by default if settings cannot be loaded. */
    }
  }

  Future<void> _loadWritingPrompt() async {
    setState(() => _promptLoading = true);
    try {
      final prompt = await sl<JournalRepository>().getWritingPrompt();
      if (mounted) {
        setState(() => _writingPrompt = prompt['prompt']?.toString());
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ide menulis belum tersedia saat ini.')),
        );
      }
    } finally {
      if (mounted) setState(() => _promptLoading = false);
    }
  }

  void _insertTemplate() {
    final template = _templates[_mode] ?? '';
    if (template.isEmpty) return;
    final existing = _contentController.text.trim();
    _contentController.text = existing.isEmpty
        ? template
        : '$existing\n\n$template';
    _contentController.selection = TextSelection.collapsed(
      offset: _contentController.text.length,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_journalBlocked) return;
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
        : tagsStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    if (widget.uuid == null) {
      context.read<JournalBloc>().add(
        JournalCreateRequested(
          title: title,
          content: content,
          moodId: _selectedMoodId,
          tags: tags,
          isPrivate: _isPrivate,
          shareWithAI: _shareWithAI,
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
          shareWithAI: _shareWithAI,
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
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Pilih Suasana Hati',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bagaimana perasaan Anda saat menulis ini?',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
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
                          _selectedMoodId = _selectedMoodId == moodId
                              ? null
                              : moodId;
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
        if (state.status == JournalStatus.success ||
            (widget.uuid != null &&
                state.status == JournalStatus.detailSuccess)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.uuid == null
                    ? 'Jurnal berhasil disimpan'
                    : 'Jurnal berhasil diperbarui',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        } else if (state.status == JournalStatus.failure &&
            state.errorMessage != null) {
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
          title: Text(
            widget.uuid == null ? 'Jurnal baru' : 'Edit jurnal',
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                  return FilledButton(
                    onPressed: isLoading || _journalBlocked ? null : _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(84, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_journalBlocked) ...[
                  _buildBlockedNotice(),
                  const SizedBox(height: 12),
                ],
                _buildMascotBanner(),
                const SizedBox(height: 16),
                _buildEditorCard(),
                if (widget.uuid == null) ...[
                  const SizedBox(height: 16),
                  _buildWritingModeCard(),
                ],
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 14),
                _buildPrivacyCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedNotice() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFFED7AA)),
    ),
    child: const Row(
      children: [
        Icon(Icons.lock_outline_rounded, color: AppColors.accentOrangeDark),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Akses menulis jurnal sedang diblokir untuk akun ini.',
            style: TextStyle(
              color: AppColors.accentOrangeText,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMascotBanner() => Container(
    height: 138,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFECEE), Color(0xFFFFF8F2)],
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: AppColors.red100),
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 15, 118, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RUANG UNTUK DIRIMU',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tulis apa yang sedang terasa',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.foreground,
                  fontSize: 17,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Tidak harus rapi. Mulai saja dari dirimu.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -4,
          bottom: -11,
          width: 126,
          height: 150,
          child: Image.asset(
            'assets/images/mascot/journal.webp',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
        ),
      ],
    ),
  );

  Widget _buildEditorCard() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      boxShadow: [
        BoxShadow(
          color: AppColors.foreground.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatanmu',
                      style: TextStyle(
                        color: AppColors.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tulis dengan nyaman, satu kalimat pun cukup.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            child: TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Judul jurnal',
                hintStyle: TextStyle(
                  color: AppColors.mutedForeground.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.65)),
        TextField(
          controller: _contentController,
          minLines: 9,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 15,
            height: 1.65,
            color: AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: 'Apa yang sedang kamu pikirkan atau rasakan hari ini?',
            hintStyle: TextStyle(
              color: AppColors.mutedForeground.withValues(alpha: 0.65),
              height: 1.55,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(17, 16, 17, 20),
          ),
        ),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.65)),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _contentController,
          builder: (context, value, child) {
            final trimmed = value.text.trim();
            final wordCount = trimmed.isEmpty
                ? 0
                : trimmed.split(RegExp(r'\s+')).length;
            return Container(
              color: AppColors.gray50,
              padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
              child: Row(
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 15,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$wordCount kata',
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.save_outlined,
                    size: 13,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(width: 5),
                  const Flexible(
                    child: Text(
                      'Disimpan saat menekan Simpan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.gray500, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildWritingModeCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cara menulis',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Pilih gaya yang terasa paling nyaman.',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _modes.entries.map((entry) {
            final selected = _mode == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              showCheckmark: false,
              avatar: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.primary,
                    )
                  : null,
              labelStyle: TextStyle(
                color: selected ? AppColors.red700 : AppColors.gray700,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              backgroundColor: AppColors.gray50,
              selectedColor: AppColors.red50,
              side: BorderSide(
                color: selected ? AppColors.red200 : AppColors.gray100,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) => setState(() => _mode = entry.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _modeDescription,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            OutlinedButton.icon(
              onPressed: _mode == 'brain-dump' ? null : _insertTemplate,
              icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
              label: const Text('Gunakan kerangka'),
              style: _editorActionStyle,
            ),
            OutlinedButton.icon(
              onPressed: _promptLoading ? null : _loadWritingPrompt,
              icon: _promptLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lightbulb_outline_rounded, size: 16),
              label: Text(_promptLoading ? 'Memuat ide…' : 'Cari ide menulis'),
              style: _editorActionStyle,
            ),
          ],
        ),
        if (_writingPrompt != null && _writingPrompt!.isNotEmpty) ...[
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(13, 12, 10, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F1),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFFDE7D1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IDE UNTUKMU',
                  style: TextStyle(
                    color: AppColors.accentOrangeDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _writingPrompt!,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _appendWritingPrompt,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Tambahkan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  void _appendWritingPrompt() {
    final prompt = _writingPrompt;
    if (prompt == null || prompt.isEmpty) return;
    final text = _contentController.text.trim();
    _contentController.text = text.isEmpty
        ? '$prompt\n\n'
        : '$text\n\n$prompt\n\n';
    _contentController.selection = TextSelection.collapsed(
      offset: _contentController.text.length,
    );
  }

  String get _modeDescription {
    switch (_mode) {
      case 'brain-dump':
        return 'Tulis apa saja yang terlintas tanpa perlu menyusunnya.';
      case 'gratitude':
        return 'Catat hal-hal kecil yang kamu syukuri hari ini.';
      case 'action-plan':
        return 'Ubah hal yang mengganggu pikiran menjadi langkah kecil.';
      default:
        return 'Ikuti pertanyaan sederhana untuk memahami perasaanmu.';
    }
  }

  Widget _buildDetailsCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suasana & tag',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Tambahkan konteks kecil untuk jurnal ini.',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tagsController,
          textCapitalization: TextCapitalization.none,
          style: const TextStyle(
            color: AppColors.foreground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Tambah tag, pisahkan dengan koma',
            hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 11),
            prefixIcon: const Icon(
              Icons.sell_outlined,
              color: AppColors.gray400,
              size: 18,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showMoodPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _selectedMoodId == null
                  ? AppColors.background
                  : AppColors.red50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedMoodId == null
                    ? AppColors.border
                    : AppColors.red100,
              ),
            ),
            child: Row(
              children: [
                if (_selectedMoodId != null)
                  MoodEmoji(moodIndex: _selectedMoodId!, size: 28)
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mood_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMoodId == null
                            ? 'Pilih suasana hati'
                            : Helpers.getMoodLabel(_selectedMoodId!),
                        style: TextStyle(
                          color: _selectedMoodId == null
                              ? AppColors.gray700
                              : AppColors.red700,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedMoodId == null
                            ? 'Beri nama pada perasaanmu'
                            : 'Mood ditambahkan ke jurnal',
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPrivacyCard() => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
    ),
    child: Column(
      children: [
        _buildSettingRow(
          icon: _isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded,
          iconColor: _isPrivate ? AppColors.gray700 : AppColors.primary,
          iconBackground: _isPrivate ? AppColors.gray100 : AppColors.red50,
          title: _isPrivate ? 'Jurnal privat' : 'Publik di komunitas',
          subtitle: _isPrivate
              ? 'Hanya kamu yang bisa membaca jurnal ini.'
              : 'Tampil di komunitas setelah lolos moderasi.',
          value: !_isPrivate,
          onChanged: (value) => setState(() => _isPrivate = !value),
        ),
        Divider(
          height: 1,
          indent: 62,
          color: AppColors.border.withValues(alpha: 0.72),
        ),
        _buildSettingRow(
          icon: _shareWithAI
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          iconColor: _shareWithAI ? AppColors.primary : AppColors.gray700,
          iconBackground: _shareWithAI ? AppColors.red50 : AppColors.gray100,
          title: 'Bagikan konteks ke AI',
          subtitle: _shareWithAI
              ? 'Teman Cerita AI boleh merujuk jurnal ini.'
              : 'Jurnal ini tidak digunakan sebagai konteks AI.',
          value: _shareWithAI,
          onChanged: (value) => setState(() => _shareWithAI = value),
        ),
      ],
    ),
  );

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: _journalBlocked ? null : onChanged,
        ),
      ],
    ),
  );

  ButtonStyle get _editorActionStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    backgroundColor: AppColors.card,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
  );
}
