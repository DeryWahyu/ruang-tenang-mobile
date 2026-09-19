import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/mindful_runner_engine.dart';
import '../widgets/mindful_runner_painter.dart';

/// Mini game Mindful Runner yang dapat dimainkan sepenuhnya secara offline.
///
/// Logika game tetap berada di [MindfulRunnerEngine], sedangkan screen ini
/// menangani HUD, input, penyimpanan skor lokal, dan layout responsif.
class MindfulRunnerScreen extends StatefulWidget {
  const MindfulRunnerScreen({super.key});

  @override
  State<MindfulRunnerScreen> createState() => _MindfulRunnerScreenState();
}

class _MindfulRunnerScreenState extends State<MindfulRunnerScreen>
    with SingleTickerProviderStateMixin {
  final MindfulRunnerEngine _engine = MindfulRunnerEngine();
  final FocusNode _focusNode = FocusNode();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = sl<SharedPreferences>();
    final highScore = prefs.getInt(StorageKeys.mindfulRunnerHighScore) ?? 0;
    if (!mounted) return;
    setState(() => _engine.highScore = highScore);
  }

  Future<void> _saveHighScore() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setInt(StorageKeys.mindfulRunnerHighScore, _engine.highScore);
  }

  void _onTick(Duration elapsed) {
    if (_engine.status != GameStatus.playing) return;
    if (elapsed - _lastTick < const Duration(milliseconds: 16)) return;
    _lastTick = elapsed;

    final result = _engine.step();
    if (result.collided) {
      HapticFeedback.mediumImpact();
      _saveHighScore();
    } else if (result.collected) {
      HapticFeedback.selectionClick();
    }
    if (mounted) setState(() {});
  }

  void _startGame() {
    if (_engine.status == GameStatus.playing) return;
    setState(_engine.start);
    _focusNode.requestFocus();
  }

  void _jump() {
    if (_engine.status != GameStatus.playing) return;
    _engine.jump();
    HapticFeedback.lightImpact();
  }

  void _releaseJump() {
    _engine.releaseJump();
  }

  void _handleKey(KeyEvent event) {
    final key = event.logicalKey;
    final isJumpKey =
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.enter;
    if (!isJumpKey) return;

    if (event is KeyDownEvent) {
      if (_engine.status == GameStatus.playing) {
        _jump();
      } else {
        _startGame();
      }
    } else if (event is KeyUpEvent) {
      _releaseJump();
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accentOrange;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mindful Runner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 600
                  ? 24.0
                  : 16.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntro(accent),
                        const SizedBox(height: 18),
                        _buildArena(accent, reduceMotion),
                        const SizedBox(height: 14),
                        _buildInstructions(accent),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentOrangeSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accentOrangeBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 15,
                color: AppColors.accentOrangeDark,
              ),
              SizedBox(width: 7),
              Text(
                'MINDFUL BREAK',
                style: TextStyle(
                  color: AppColors.accentOrangeDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Perjalanan tenangmu',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Lewati beban pikiran, temukan ritme, dan kumpulkan momen yang membuat langkah terasa lebih ringan.',
          style: TextStyle(
            color: AppColors.mutedForeground,
            height: 1.55,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetaChip(Icons.schedule_rounded, 'Jeda 2–3 menit', accent),
            _buildMetaChip(Icons.wifi_off_rounded, 'Tersedia offline', accent),
            _buildMetaChip(
              Icons.favorite_outline_rounded,
              'Ruang aman',
              accent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArena(Color accent, bool reduceMotion) {
    final isPlaying = _engine.status == GameStatus.playing;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentOrangeSoft,
            AppColors.card,
            AppColors.accentOrangeLight,
          ],
          stops: [0, 0.54, 1],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accentOrangeBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Semantics(
        label: isPlaying
            ? 'Mindful Runner sedang dimainkan. Skor ${_engine.score}.'
            : 'Arena Mindful Runner',
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: isPlaying ? (_) => _jump() : null,
          onPointerUp: isPlaying ? (_) => _releaseJump() : null,
          onPointerCancel: isPlaying ? (_) => _releaseJump() : null,
          child: AspectRatio(
            aspectRatio: kCanvasW / kCanvasH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: MindfulRunnerPainter(
                        _engine,
                        accent: accent,
                        reduceMotion: reduceMotion,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  if (isPlaying) _buildHud(accent),
                  if (!isPlaying) _buildOverlay(accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHud(Color accent) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: _hudDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SKOR PERJALANAN',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    '${_engine.score}',
                    style: const TextStyle(
                      color: AppColors.gray800,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildHudPill(
                    Icons.emoji_events_rounded,
                    '${_engine.highScore}',
                    AppColors.warning,
                  ),
                  if (_engine.combo > 1)
                    _buildHudPill(
                      Icons.auto_awesome_rounded,
                      '×${_engine.combo}',
                      accent,
                    ),
                  if (_engine.hasShield)
                    _buildHudPill(
                      Icons.shield_outlined,
                      '${(_engine.shieldFrames / 60).ceil()}s',
                      accent,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _hudDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x140F172A),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildHudPill(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: _hudDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(Color accent) {
    final isOver = _engine.status == GameStatus.over;

    return ColoredBox(
      color: AppColors.gray900.withValues(alpha: 0.04),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x290F172A),
                  blurRadius: 34,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrangeLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isOver
                        ? Icons.favorite_rounded
                        : Icons.auto_awesome_rounded,
                    size: 22,
                    color: isOver ? AppColors.red400 : accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isOver ? 'JEDA SEJENAK' : 'MINDFUL BREAK',
                  style: const TextStyle(
                    color: AppColors.gray400,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isOver ? 'Perjalanan selesai' : 'Mulai perjalanan tenang',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  isOver
                      ? _engine.overMessage
                      : 'Lewati beban pikiran dan kumpulkan momen yang membuat langkahmu terasa lebih ringan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                if (isOver) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildResultValue('SKOR', _engine.score),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.border,
                        ),
                        _buildResultValue('TERBAIK', _engine.highScore),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _startGame,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: Icon(
                    isOver ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    size: 19,
                  ),
                  label: Text(
                    isOver ? 'Coba lagi' : 'Mulai bermain',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultValue(String label, int value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray400,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.gray800,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cara bermain',
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tahan layar untuk melompat lebih tinggi. Ketuk lagi di udara untuk lompatan ganda.',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegend(
                Icons.favorite_rounded,
                'Kepedulian diri',
                AppColors.red400,
              ),
              _buildLegend(Icons.star_rounded, 'Kejernihan', AppColors.warning),
              _buildLegend(Icons.shield_rounded, 'Perisai Tenang', accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
