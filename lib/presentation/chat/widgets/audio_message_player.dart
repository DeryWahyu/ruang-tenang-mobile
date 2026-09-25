import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/api_constants.dart';

class AudioMessagePlayer extends StatefulWidget {
  final String source;
  final bool isUser;
  const AudioMessagePlayer({
    super.key,
    required this.source,
    required this.isUser,
  });
  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (_player.playing) {
      await _player.pause();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!_loaded) {
        final source = widget.source.startsWith('http')
            ? widget.source
            : '${ApiConstants.baseUrl}${widget.source.startsWith('/') ? '' : '/'}${widget.source}';
        await _player.setUrl(source);
        _loaded = true;
      }
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      _player.play();
    } catch (_) {
      if (mounted) setState(() => _error = 'Audio belum bisa diputar');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<PlayerState>(
    stream: _player.playerStateStream,
    builder: (context, snapshot) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _busy ? null : _toggle,
          icon: Icon(
            _busy
                ? Icons.hourglass_empty
                : _player.playing
                ? Icons.pause_circle
                : Icons.play_circle,
          ),
        ),
        Text(
          _error ?? 'Pesan suara',
          style: TextStyle(color: widget.isUser ? Colors.white : null),
        ),
      ],
    ),
  );
}
