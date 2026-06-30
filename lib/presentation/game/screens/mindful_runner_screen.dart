import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/mindful_runner_engine.dart';
import '../widgets/mindful_runner_painter.dart';

/// Layar **Mini Game — Mindful Runner** (offline penuh).
///
/// Endless runner ala "dino jump": ketuk layar / tekan SPASI atau ↑ untuk
/// melompati pikiran negatif dan mengumpulkan hati, bintang, dan lotus.
/// Game loop digerakkan oleh [Ticker] (~setiap frame), rendering via
/// [MindfulRunnerPainter]. Skor terbaik disimpan lokal (SharedPreferences)
/// sehingga tetap berfungsi tanpa internet.
class MindfulRunnerScreen extends StatefulWidget {
  const MindfulRunnerScreen({super.key});

  @override
  State<MindfulRunnerScreen> createState() => _MindfulRunnerScreenState();
}

class _MindfulRunnerScreenState extends State<MindfulRunnerScreen>
    with SingleTickerProviderStateMixin {
  final MindfulRunnerEngine _engine = MindfulRunnerEngine();
  late final Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = sl<SharedPreferences>();
    setState(() {
      _engine.highScore = prefs.getInt(StorageKeys.mindfulRunnerHighScore) ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setInt(StorageKeys.mindfulRunnerHighScore, _engine.highScore);
  }

  /// Dipanggil tiap frame oleh ticker. Membatasi update ~60fps dan
  /// menjalankan satu langkah engine ketika sedang bermain.
  void _onTick(Duration elapsed) {
    // Throttle ke ~60fps (16ms) agar kecepatan konsisten lintas perangkat.
    if (elapsed - _lastTick < const Duration(milliseconds: 16)) return;
    _lastTick = elapsed;

    if (_engine.status == GameStatus.playing) {
      final result = _engine.step();
      if (result.collided) {
        HapticFeedback.mediumImpact();
        _saveHighScore();
      } else if (result.collected) {
        HapticFeedback.selectionClick();
      }
    }
    if (mounted) setState(() {});
  }

  void _handlePressDown() {
    if (_engine.status == GameStatus.playing) {
      _engine.jump();
      HapticFeedback.lightImpact();
    } else {
      setState(_engine.start);
    }
  }

  void _handlePressUp() {
    // Lepas tombol → hentikan variable jump (turun lebih cepat).
    _engine.releaseJump();
  }

  void _handleKey(KeyEvent event) {
    final key = event.logicalKey;
    final isJumpKey = key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.enter;
    if (!isJumpKey) return;
    if (event is KeyDownEvent) {
      _handlePressDown();
    } else if (event is KeyUpEvent) {
      _handlePressUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mindful Runner', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _handlePressDown(),
          onPointerUp: (_) => _handlePressUp(),
          onPointerCancel: (_) => _handlePressUp(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: kCanvasW / kCanvasH,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.red200),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Kanvas game — diisolasi dgn RepaintBoundary
                                // agar repaint tiap frame tidak memicu repaint
                                // widget lain di pohon.
                                RepaintBoundary(
                                  child: CustomPaint(
                                    painter: MindfulRunnerPainter(_engine),
                                    size: Size.infinite,
                                  ),
                                ),
                                // Overlay idle / game over.
                                if (_engine.status != GameStatus.playing) _buildOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ketuk/tahan untuk melompat (tahan = lebih tinggi) • Ketuk lagi di udara untuk lompat ganda • Lotus 🪷 memberi perisai',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final isOver = _engine.status == GameStatus.over;
    return Container(
      color: Colors.white.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOver ? Icons.self_improvement_rounded : Icons.directions_run_rounded,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              isOver ? 'Permainan Selesai' : 'Mindful Runner',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              isOver ? _engine.overMessage : 'Hindari pikiran negatif, kumpulkan ketenangan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            if (isOver) ...[
              const SizedBox(height: 12),
              Text('Skor: ${_engine.score}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              if (_engine.highScore > 0)
                Text('Skor Terbaik: ${_engine.highScore}',
                    style: const TextStyle(color: AppColors.mutedForeground)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _handlePressDown,
              icon: Icon(isOver ? Icons.replay_rounded : Icons.play_arrow_rounded),
              label: Text(isOver ? 'Coba Lagi' : 'Mulai'),
            ),
          ],
        ),
      ),
    );
  }
}
