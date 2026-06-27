import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/journal.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_input.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

/// Create / edit journal screen.
///
/// Pass an existing [Journal] to edit it; omit it (or pass uuid only) to
/// create a new entry.
class JournalCreateScreen extends StatefulWidget {
  final String? uuid;
  final Journal? journal;

  const JournalCreateScreen({super.key, this.uuid, this.journal});

  @override
  State<JournalCreateScreen> createState() => _JournalCreateScreenState();
}

class _JournalCreateScreenState extends State<JournalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  List<String> _tags = [];

  bool get _isEditing => widget.journal != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal?.title ?? '');
    _contentController = TextEditingController(text: widget.journal?.content ?? '');
    _tagController = TextEditingController();
    _tags = List<String>.from(widget.journal?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().replaceAll(RegExp(r'\s+'), '_');
    if (tag.isEmpty) return;
    if (!_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _onSubmit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi jurnal tidak boleh kosong.'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final bloc = context.read<JournalBloc>();
    if (_isEditing) {
      bloc.add(JournalUpdateRequested(
        uuid: widget.uuid!,
        title: title,
        content: content,
        tags: _tags,
      ));
    } else {
      bloc.add(JournalCreateRequested(
        title: title,
        content: content,
        tags: _tags,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JournalBloc, JournalState>(
      listener: (context, state) {
        final isSaved = state.status == JournalStatus.success ||
            (state.status == JournalStatus.detailSuccess && _isEditing);
        if (isSaved && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(true);
        }
        if (state.status == JournalStatus.failure && state.errorMessage != null) {
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
          title: Text(_isEditing ? 'Edit Jurnal' : 'Tulis Jurnal'),
          centerTitle: false,
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingBase),
              children: [
                AppInput(
                  label: 'Judul',
                  hint: 'Beri judul untuk jurnalmu (opsional)',
                  controller: _titleController,
                  prefixIcon: Icons.title_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v != null && v.trim().length > 120 ? 'Judul maksimal 120 karakter' : null,
                ),
                const SizedBox(height: AppDimensions.spacingBase),
                AppInput(
                  label: 'Cerita & Pikiran',
                  hint: 'Tulis apa yang kamu rasakan hari ini...',
                  controller: _contentController,
                  maxLines: 12,
                  minLines: 8,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  validator: (v) =>
                      Validators.minLength(v, 1, 'Isi jurnal'),
                ),
                const SizedBox(height: AppDimensions.spacingBase),
                _buildTagInput(),
                const SizedBox(height: AppDimensions.spacing2xl),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Tambah tag lalu Enter',
                  prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.mutedForeground),
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    borderSide: const BorderSide(color: AppColors.input),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    borderSide: const BorderSide(color: AppColors.input),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add_circle_rounded),
              color: AppColors.primary,
              iconSize: 32,
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .map((tag) => Chip(
                      label: Text('#$tag'),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: AppColors.red50,
                      labelStyle: const TextStyle(color: AppColors.red700, fontSize: 13),
                      deleteIconColor: AppColors.red700,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<JournalBloc, JournalState>(
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingBase,
              AppDimensions.spacingSm,
              AppDimensions.spacingBase,
              AppDimensions.spacingSm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: AppButton.primary(
              label: _isEditing ? 'Simpan Perubahan' : 'Simpan Jurnal',
              isLoading: state.isSubmitting,
              onPressed: _onSubmit,
              suffixIcon: Icons.check_rounded,
            ),
          ),
        );
      },
    );
  }
}
