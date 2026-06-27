import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingBase,
        AppDimensions.spacingSm,
        AppDimensions.spacingBase,
        MediaQuery.paddingOf(context).bottom + AppDimensions.spacingSm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                filled: true,
                fillColor: AppColors.muted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingMd,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryForeground,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: AppColors.primaryForeground),
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
