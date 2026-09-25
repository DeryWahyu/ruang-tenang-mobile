import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/platform/voice_input_service.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final Future<void> Function(File)? onSendAudio;
  final bool isLoading;
  final String? initialText;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onSendAudio,
    this.isLoading = false,
    this.initialText,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late final TextEditingController _controller;
  bool _hasText = false;
  bool _recording = false;
  bool _voiceBusy = false;
  final _voice = VoiceInputService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
  }

  @override
  void dispose() {
    if (_recording) _voice.cancelRecording();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dictate() async {
    setState(() => _voiceBusy = true);
    try {
      final words = await _voice.dictate();
      if (mounted && words.isNotEmpty) {
        _controller.text =
            '${_controller.text}${_controller.text.isEmpty ? '' : ' '}$words';
      }
    } catch (_) {
      _voiceError('Dikte suara belum tersedia. Periksa izin mikrofon.');
    } finally {
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      setState(() {
        _recording = false;
        _voiceBusy = true;
      });
      try {
        final file = await _voice.stopRecording();
        await widget.onSendAudio?.call(file);
      } catch (_) {
        _voiceError('Pesan suara belum berhasil dikirim.');
      } finally {
        if (mounted) setState(() => _voiceBusy = false);
      }
      return;
    }
    try {
      await _voice.startRecording();
      if (mounted) setState(() => _recording = true);
    } catch (_) {
      _voiceError('Rekaman belum bisa dimulai. Periksa izin mikrofon.');
    }
  }

  void _voiceError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'Dikte suara',
            onPressed: _voiceBusy || _recording || widget.isLoading
                ? null
                : _dictate,
            icon: const Icon(Icons.keyboard_voice_outlined),
          ),
          if (widget.onSendAudio != null)
            IconButton(
              tooltip: _recording ? 'Kirim rekaman' : 'Rekam pesan suara',
              onPressed: _voiceBusy || widget.isLoading
                  ? null
                  : _toggleRecording,
              icon: Icon(
                _recording ? Icons.stop_circle : Icons.mic_none,
                color: _recording ? Colors.red : null,
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan Anda...',
                  hintStyle: TextStyle(color: AppColors.mutedForeground),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _hasText ? AppColors.primary : AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _hasText ? _handleSend : null,
                customBorder: const CircleBorder(),
                child: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_upward_rounded,
                        color: _hasText
                            ? Colors.white
                            : AppColors.mutedForeground,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
