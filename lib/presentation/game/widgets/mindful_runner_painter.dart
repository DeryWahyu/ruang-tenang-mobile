import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/mindful_runner_engine.dart';

/// Menggambar dunia [MindfulRunnerEngine] memakai kanvas logis 1400×420
/// lalu menskalakannya agar pas pada ukuran widget. Meniru tampilan versi web
/// (langit gradient, matahari, awan, tanah bertitik, pemain, rintangan
/// "pikiran negatif", collectible, partikel, afirmasi, HUD).
class MindfulRunnerPainter extends CustomPainter {
  final MindfulRunnerEngine engine;

  MindfulRunnerPainter(this.engine) : super(repaint: null);

  // Palet warna selaras tema merah web.
  static const _sky = Color(0xFFFEF2F2);
  static const _skyTop = Color(0xFFEFF6FF);
  static const _ground = Color(0xFFFCA5A5);
  static const _groundLine = Color(0xFFEF4444);
  static const _player = Color(0xFFEF4444);
  static const _playerAlt = Color(0xFFDC2626);
  static const _obstacle = Color(0xFF6B7280);
  static const _obstacleDark = Color(0xFF374151);
  static const _collectibleGlow = Color(0xFFFEE2E2);
  static const _cloud = Color(0xFFFFFFFF);
  static const _text = Color(0xFF111827);
  static const _textLight = Color(0xFF6B7280);
  static const _sun = Color(0xFFFBBF24);
  static const _sunGlow = Color(0xFFFEF3C7);
  static const _flower = Color(0xFFF472B6);
  static const _flowerCenter = Color(0xFFFBBF24);
  static const _leaf = Color(0xFF34D399);
  static const _heart = Color(0xFFEF4444);
  static const _star = Color(0xFFFBBF24);

  @override
  void paint(Canvas canvas, Size size) {
    // Skala kanvas logis → ukuran widget (jaga rasio dengan fit lebar).
    final scale = size.width / kCanvasW;
    canvas.save();
    canvas.scale(scale, scale);
    // Tinggi terlihat = size.height / scale; gambar tetap pakai koordinat logis.

    if (engine.shakeLife > 0) {
      canvas.translate(engine.shakeX, engine.shakeY);
    }

    _drawBackground(canvas);
    for (final c in engine.collectibles) {
      _drawCollectible(canvas, c, engine.frameCount);
    }
    for (final o in engine.obstacles) {
      _drawObstacle(canvas, o);
    }
    _drawPlayer(canvas, engine.playerY, engine.playerFrame);
    _drawParticles(canvas);
    _drawFloatingTexts(canvas);
    _drawAffirmation(canvas);
    _drawHud(canvas);

    if (engine.status == GameStatus.over) {
      // Kilatan merah halus saat tabrakan.
      final p = Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.14);
      canvas.drawRect(const Rect.fromLTWH(0, 0, kCanvasW, kCanvasH), p);
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    // Langit gradient.
    final skyRect = const Rect.fromLTWH(0, 0, kCanvasW, kCanvasH);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skyTop, _sky],
      ).createShader(const Rect.fromLTWH(0, 0, kCanvasW, kGroundY));
    canvas.drawRect(skyRect, skyPaint);

    // Matahari + glow.
    canvas.drawCircle(const Offset(kCanvasW - 80, 50), 30,
        Paint()..color = _sunGlow.withValues(alpha: 0.4));
    canvas.drawCircle(const Offset(kCanvasW - 80, 50), 18, Paint()..color = _sun);

    // Lapisan awan jauh (parallax lambat) untuk kedalaman.
    final farCloud = Paint()..color = _cloud.withValues(alpha: 0.4);
    for (var i = 0; i < 3; i++) {
      final fx = ((i * 520 + 120 - engine.frameCount * 0.4) % (kCanvasW + 240)) - 120;
      final fy = 30.0 + i * 22;
      canvas.drawCircle(Offset(fx, fy), 26, farCloud);
      canvas.drawCircle(Offset(fx + 26, fy - 6), 20, farCloud);
      canvas.drawCircle(Offset(fx + 52, fy), 26, farCloud);
    }

    // Awan (parallax dekat).
    for (final cloud in engine.clouds) {
      final cp = Paint()..color = _cloud.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(cloud.x, cloud.y), cloud.width * 0.3, cp);
      canvas.drawCircle(Offset(cloud.x + cloud.width * 0.3, cloud.y - 5), cloud.width * 0.25, cp);
      canvas.drawCircle(Offset(cloud.x + cloud.width * 0.6, cloud.y), cloud.width * 0.3, cp);
    }

    // Tanah.
    canvas.drawRect(
      const Rect.fromLTWH(0, kGroundY + 24, kCanvasW, kCanvasH - kGroundY - 24),
      Paint()..color = _ground,
    );
    canvas.drawLine(
      const Offset(0, kGroundY + 24),
      const Offset(kCanvasW, kGroundY + 24),
      Paint()
        ..color = _groundLine
        ..strokeWidth = 2,
    );

    // Titik tanah bergerak (kesan berlari).
    final dotPaint = Paint()..color = _groundLine.withValues(alpha: 0.3);
    final scrollOffset = (engine.frameCount * engine.speed) % 20;
    for (var i = -1; i < kCanvasW / 20 + 1; i++) {
      canvas.drawCircle(Offset(i * 20 - scrollOffset, kGroundY + 40), 1.5, dotPaint);
    }

    // Bunga kecil di tanah (parallax lambat).
    for (var i = 0; i < 5; i++) {
      final fx = ((i * 173 + 50 - engine.frameCount * engine.speed * 0.3) % (kCanvasW + 100)) - 50;
      canvas.drawRect(Rect.fromLTWH(fx, kGroundY + 18, 2, 6), Paint()..color = _leaf);
      canvas.drawCircle(Offset(fx + 1, kGroundY + 16), 3,
          Paint()..color = i.isEven ? _flower : _player);
    }
  }

  void _drawPlayer(Canvas canvas, double y, int frame) {
    const x = 60.0;
    final bobY = engine.isJumping ? 0.0 : sin(frame * 0.1) * 3;
    final pY = y + bobY;

    // Bayangan.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(x + 12, kGroundY + 24), width: 28, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    // Aura perisai (lotus) — cincin bercahaya berdenyut di sekeliling pemain.
    if (engine.hasShield) {
      final pulse = 0.5 + sin(frame * 0.2) * 0.2;
      canvas.drawCircle(
        Offset(x + 12, pY - 12), 26,
        Paint()..color = _flower.withValues(alpha: 0.18 * pulse),
      );
      canvas.drawCircle(
        Offset(x + 12, pY - 12), 24,
        Paint()
          ..color = _flower.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Badan & kepala.
    canvas.drawCircle(Offset(x + 12, pY - 8), 10, Paint()..color = _player);
    canvas.drawCircle(Offset(x + 12, pY - 24), 8, Paint()..color = _playerAlt);

    // Mata (terpejam/tenang) & senyum.
    final face = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(Rect.fromCircle(center: Offset(x + 9, pY - 25), radius: 2), 0, pi, false, face);
    canvas.drawArc(Rect.fromCircle(center: Offset(x + 15, pY - 25), radius: 2), 0, pi, false, face);
    canvas.drawArc(Rect.fromCircle(center: Offset(x + 12, pY - 22), radius: 3), 0.1 * pi, 0.8 * pi, false, face);

    // Kaki.
    final legPaint = Paint()
      ..color = _player
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (!engine.isJumping) {
      final legAngle = sin(frame * 0.25) * 0.5;
      canvas.drawLine(Offset(x + 8, pY + 2), Offset(x + 8 + sin(legAngle) * 8, pY + 20), legPaint);
      canvas.drawLine(Offset(x + 16, pY + 2), Offset(x + 16 + sin(-legAngle) * 8, pY + 20), legPaint);
    } else {
      canvas.drawLine(Offset(x + 8, pY + 2), Offset(x + 4, pY + 12), legPaint);
      canvas.drawLine(Offset(x + 16, pY + 2), Offset(x + 20, pY + 12), legPaint);
    }

    // Lengan.
    final armPaint = Paint()
      ..color = _playerAlt
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (engine.isJumping) {
      canvas.drawLine(Offset(x + 4, pY - 10), Offset(x - 4, pY - 20), armPaint);
      canvas.drawLine(Offset(x + 20, pY - 10), Offset(x + 28, pY - 20), armPaint);
    } else {
      final armSwing = sin(frame * 0.25) * 6;
      canvas.drawLine(Offset(x + 4, pY - 10), Offset(x - 2 + armSwing, pY + 4), armPaint);
      canvas.drawLine(Offset(x + 20, pY - 10), Offset(x + 26 - armSwing, pY + 4), armPaint);
    }
  }

  void _drawObstacle(Canvas canvas, Obstacle obs) {
    final bx = obs.x;
    final by = kGroundY + 24 - obs.height;
    final paint = Paint()..color = _obstacle;

    if (obs.type == ObstacleType.spiral) {
      canvas.drawCircle(Offset(bx + obs.width / 2, by + obs.height / 2), obs.width / 2, paint);
      final stroke = Paint()
        ..color = _obstacleDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 3; i++) {
        final r = (obs.width / 2) * (0.3 + i * 0.2);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(bx + obs.width / 2, by + obs.height / 2), radius: r),
          i * 0.5, pi, false, stroke,
        );
      }
    } else if (obs.type == ObstacleType.stress) {
      final cx = bx + obs.width / 2;
      final path = Path()
        ..moveTo(cx - 5, by)
        ..lineTo(cx + 8, by + obs.height * 0.35)
        ..lineTo(cx + 2, by + obs.height * 0.35)
        ..lineTo(cx + 10, by + obs.height)
        ..lineTo(cx - 3, by + obs.height * 0.55)
        ..lineTo(cx + 3, by + obs.height * 0.55)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, obs.width, obs.height), const Radius.circular(8)),
        paint,
      );
      final dark = Paint()..color = _obstacleDark;
      canvas.drawCircle(Offset(bx + 8, by + obs.height + 4), 4, dark);
      canvas.drawCircle(Offset(bx + 2, by + obs.height + 10), 2, dark);
    }

    // Label pikiran negatif.
    _drawText(
      canvas, obs.label, Offset(bx + obs.width / 2, by + obs.height / 2),
      color: Colors.white, fontSize: 9, bold: true, center: true,
    );
  }

  void _drawCollectible(Canvas canvas, Collectible c, int frame) {
    if (c.collected) return;
    final bob = sin(frame * 0.08 + c.x) * 4;
    final cx = c.x;
    final cy = c.y + bob;

    // Glow.
    canvas.drawCircle(
      Offset(cx, cy), 14,
      Paint()..color = _collectibleGlow.withValues(alpha: 0.3 + sin(frame * 0.1) * 0.15),
    );

    switch (c.type) {
      case CollectibleType.heart:
        final path = Path()
          ..moveTo(cx, cy + 4)
          ..cubicTo(cx - 8, cy - 4, cx - 8, cy - 10, cx, cy - 6)
          ..cubicTo(cx + 8, cy - 10, cx + 8, cy - 4, cx, cy + 4);
        canvas.drawPath(path, Paint()..color = _heart);
        break;
      case CollectibleType.star:
        _drawStar(canvas, cx, cy, 5, 8, 4, Paint()..color = _star);
        break;
      case CollectibleType.lotus:
        final petal = Paint()..color = _flower;
        for (var i = 0; i < 5; i++) {
          final a = (i * pi * 2) / 5 - pi / 2;
          canvas.save();
          canvas.translate(cx + cos(a) * 4, cy + sin(a) * 4);
          canvas.rotate(a);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 10, height: 6), petal);
          canvas.restore();
        }
        canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = _flowerCenter);
        break;
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in engine.particles) {
      final paint = Paint()..color = Color(p.colorValue).withValues(alpha: (p.life / p.maxLife).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in engine.floatingTexts) {
      _drawText(
        canvas, ft.text, Offset(ft.x, ft.y),
        color: _text.withValues(alpha: (ft.life / ft.maxLife).clamp(0.0, 1.0)),
        fontSize: 14, bold: true, center: true,
      );
    }
  }

  void _drawAffirmation(Canvas canvas) {
    if (engine.affirmationTimer <= 0 || engine.affirmation.isEmpty) return;
    final t = engine.affirmationTimer;
    final alpha = t > 100 ? (120 - t) / 20 : t > 20 ? 1.0 : t / 20;
    _drawText(
      canvas, engine.affirmation, const Offset(kCanvasW / 2, 40),
      color: _player.withValues(alpha: alpha.clamp(0.0, 1.0)),
      fontSize: 18, bold: true, center: true,
    );
  }

  void _drawHud(Canvas canvas) {
    _drawText(canvas, 'Skor: ${engine.score}', const Offset(12, 14), color: _text, fontSize: 14, bold: true);
    if (engine.highScore > 0) {
      _drawText(canvas, 'Terbaik: ${engine.highScore}', const Offset(12, 32), color: _textLight, fontSize: 11);
    }
    if (engine.combo > 1) {
      _drawText(canvas, 'Combo x${engine.combo}', const Offset(12, 48), color: _player, fontSize: 12, bold: true);
    }
    if (engine.hasShield) {
      final secs = (engine.shieldFrames / 60).ceil();
      _drawText(canvas, '🛡 Perisai ${secs}s', const Offset(12, 66), color: _flower, fontSize: 12, bold: true);
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, int spikes, double outerR, double innerR, Paint paint) {
    var rot = (pi / 2) * 3;
    final step = pi / spikes;
    final path = Path()..moveTo(cx, cy - outerR);
    for (var i = 0; i < spikes; i++) {
      path.lineTo(cx + cos(rot) * outerR, cy + sin(rot) * outerR);
      rot += step;
      path.lineTo(cx + cos(rot) * innerR, cy + sin(rot) * innerR);
      rot += step;
    }
    path
      ..lineTo(cx, cy - outerR)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    required Color color,
    required double fontSize,
    bool bold = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = center ? Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2) : pos;
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant MindfulRunnerPainter oldDelegate) => true;
}
