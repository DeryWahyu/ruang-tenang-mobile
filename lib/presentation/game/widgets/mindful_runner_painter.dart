import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/mindful_runner_engine.dart';

/// Renderer visual Calm Journey untuk Mindful Runner.
///
/// Engine tetap memakai koordinat logis 800×1000. Painter hanya mengatur
/// presentasi: dunia netral, aksen tema, siluet pemain, obstacle emosi, dan
/// collectible yang konsisten dengan versi web.
class MindfulRunnerPainter extends CustomPainter {
  const MindfulRunnerPainter(
    this.engine, {
    required this.accent,
    this.reduceMotion = false,
  });

  final MindfulRunnerEngine engine;
  final Color accent;
  final bool reduceMotion;

  static const _skyTop = Color(0xFFF8FAFC);
  static const _white = Color(0xFFFFFFFF);
  static const _path = Color(0xFFF8FAFC);
  static const _pathDeep = Color(0xFFE2E8F0);
  static const _ink = Color(0xFF334155);
  static const _inkSoft = Color(0xFF64748B);
  static const _obstacle = Color(0xFF64748B);
  static const _obstacleDark = Color(0xFF334155);
  static const _heart = Color(0xFFFB7185);
  static const _star = Color(0xFFFBBF24);
  static const _playerX = 72.0;

  Color get _accentDark => Color.lerp(accent, Colors.black, 0.22)!;
  Color get _accentLight => Color.lerp(accent, Colors.white, 0.78)!;
  Color get _accentSoft => Color.lerp(accent, Colors.white, 0.92)!;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width / kCanvasW, size.height / kCanvasH);
    final offsetX = (size.width - kCanvasW * scale) / 2;
    final offsetY = (size.height - kCanvasH * scale) / 2;

    canvas
      ..save()
      ..translate(offsetX, offsetY)
      ..scale(scale, scale);

    if (engine.shakeLife > 0 && !reduceMotion) {
      canvas.translate(engine.shakeX, engine.shakeY);
    }

    _drawBackground(canvas);
    for (final collectible in engine.collectibles) {
      _drawCollectible(canvas, collectible, engine.frameCount);
    }
    for (final obstacle in engine.obstacles) {
      _drawObstacle(canvas, obstacle);
    }
    _drawPlayer(canvas, engine.playerY, engine.playerFrame);
    _drawParticles(canvas);
    _drawFloatingTexts(canvas);
    _drawAffirmation(canvas);

    if (engine.status == GameStatus.over) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, kCanvasW, kCanvasH),
        Paint()..color = _heart.withValues(alpha: 0.10),
      );
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final skyRect = const Rect.fromLTWH(0, 0, kCanvasW, kCanvasH);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skyTop, _accentSoft, _white],
        stops: const [0, 0.62, 1],
      ).createShader(const Rect.fromLTWH(0, 0, kCanvasW, kGroundY + 40));
    canvas.drawRect(skyRect, skyPaint);

    final haloCenter = const Offset(kCanvasW - 115, 110);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [_accentLight, _accentLight.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: haloCenter, radius: 92));
    canvas.drawCircle(haloCenter, 92, haloPaint);
    canvas.drawCircle(
      haloCenter,
      27,
      Paint()..color = _white.withValues(alpha: 0.76),
    );

    final backOffset = reduceMotion
        ? 0.0
        : (engine.frameCount * engine.speed * 0.045) % 260;
    final backPath = Path()..moveTo(-260 - backOffset, kGroundY + 24);
    for (var index = -1; index < 5; index++) {
      final x = index * 260.0 - backOffset;
      backPath
        ..quadraticBezierTo(x + 65, kGroundY - 180, x + 130, kGroundY - 72)
        ..quadraticBezierTo(x + 195, kGroundY + 2, x + 260, kGroundY - 45);
    }
    backPath
      ..lineTo(kCanvasW, kGroundY + 24)
      ..close();
    canvas.drawPath(
      backPath,
      Paint()..color = _accentLight.withValues(alpha: 0.42),
    );

    final frontOffset = reduceMotion
        ? 0.0
        : (engine.frameCount * engine.speed * 0.09) % 210;
    final frontPath = Path()..moveTo(-210 - frontOffset, kGroundY + 24);
    for (var index = -1; index < 6; index++) {
      final x = index * 210.0 - frontOffset;
      frontPath
        ..quadraticBezierTo(x + 52, kGroundY - 95, x + 105, kGroundY - 38)
        ..quadraticBezierTo(x + 158, kGroundY + 7, x + 210, kGroundY - 22);
    }
    frontPath
      ..lineTo(kCanvasW, kGroundY + 24)
      ..close();
    canvas.drawPath(frontPath, Paint()..color = accent.withValues(alpha: 0.14));

    for (final cloud in engine.clouds) {
      final cloudPath = Path()
        ..moveTo(cloud.x, cloud.y + 76)
        ..cubicTo(
          cloud.x + cloud.width * 0.2,
          cloud.y + 56,
          cloud.x + cloud.width * 0.42,
          cloud.y + 91,
          cloud.x + cloud.width * 0.62,
          cloud.y + 73,
        )
        ..cubicTo(
          cloud.x + cloud.width * 0.75,
          cloud.y + 61,
          cloud.x + cloud.width * 0.9,
          cloud.y + 78,
          cloud.x + cloud.width,
          cloud.y + 70,
        );
      canvas.drawPath(
        cloudPath,
        Paint()
          ..color = _white.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(10.0, cloud.width * 0.14)
          ..strokeCap = StrokeCap.round,
      );
    }

    final groundRect = const Rect.fromLTWH(
      0,
      kGroundY + 24,
      kCanvasW,
      kCanvasH - kGroundY - 24,
    );
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_path, _pathDeep],
        ).createShader(groundRect),
    );
    canvas.drawLine(
      const Offset(0, kGroundY + 24),
      const Offset(kCanvasW, kGroundY + 24),
      Paint()
        ..color = accent.withValues(alpha: 0.34)
        ..strokeWidth = 3,
    );

    final trailOffset = reduceMotion
        ? 0.0
        : (engine.frameCount * engine.speed * 0.55) % 64;
    final trailPaint = Paint()
      ..color = _inkSoft.withValues(alpha: 0.16)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var x = -64.0; x < kCanvasW + 64; x += 64) {
      canvas.drawLine(
        Offset(x - trailOffset, kGroundY + 68),
        Offset(x + 22 - trailOffset, kGroundY + 68),
        trailPaint,
      );
    }
  }

  void _drawPlayer(Canvas canvas, double y, int frame) {
    final bob = engine.isJumping || reduceMotion ? 0.0 : sin(frame * 0.1) * 2;
    final playerY = y + bob;
    final groundDistance = max(0.0, kGroundY - y);
    final shadowScale = max(0.45, 1 - groundDistance / 180);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(_playerX, kGroundY + 25),
        width: 46 * shadowScale,
        height: 12 * shadowScale,
      ),
      Paint()..color = _ink.withValues(alpha: 0.12 * shadowScale),
    );

    if (engine.hasShield) {
      final pulse = reduceMotion ? 0.72 : 0.68 + sin(frame * 0.16) * 0.08;
      canvas.drawCircle(
        Offset(_playerX, playerY - 11),
        43,
        Paint()..color = _accentLight.withValues(alpha: 0.20),
      );
      canvas.drawCircle(
        Offset(_playerX, playerY - 11),
        38,
        Paint()
          ..color = accent.withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    final stride = engine.isJumping ? 0.0 : sin(frame * 0.24);
    final armSwing = engine.isJumping ? -5.0 : stride * 7;

    final scarfPath = Path()
      ..moveTo(_playerX - 3, playerY - 19)
      ..cubicTo(
        _playerX - 17,
        playerY - 17,
        _playerX - 27 - stride.abs() * 4,
        playerY - 11,
        _playerX - 37,
        playerY - 17 + stride * 2,
      );
    canvas.drawPath(
      scarfPath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    final limbPaint = Paint()
      ..color = _ink
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(_playerX - 5, playerY + 3),
        Offset(_playerX - 7 + stride * 9, playerY + 26),
        limbPaint,
      )
      ..drawLine(
        Offset(_playerX + 5, playerY + 3),
        Offset(_playerX + 8 - stride * 9, playerY + 26),
        limbPaint,
      );

    final armPaint = Paint()
      ..color = _ink
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(_playerX - 9, playerY - 12),
        Offset(
          _playerX - 19 + armSwing,
          playerY + (engine.isJumping ? -25 : 5),
        ),
        armPaint,
      )
      ..drawLine(
        Offset(_playerX + 9, playerY - 12),
        Offset(
          _playerX + 19 - armSwing,
          playerY + (engine.isJumping ? -25 : 5),
        ),
        armPaint,
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_playerX - 11, playerY - 23, 22, 32),
        const Radius.circular(11),
      ),
      Paint()..color = _ink,
    );
    canvas.drawCircle(
      Offset(_playerX, playerY - 38),
      11,
      Paint()..color = _ink,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(_playerX + 2, playerY - 37), radius: 4),
      0.1 * pi,
      0.72 * pi,
      false,
      Paint()
        ..color = _white.withValues(alpha: 0.76)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  void _drawObstacle(Canvas canvas, Obstacle obstacle) {
    final x = obstacle.x;
    final y = kGroundY + 24 - obstacle.height;
    final centerX = x + obstacle.width / 2;
    final centerY = y + obstacle.height / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, kGroundY + 27),
        width: obstacle.width * 1.15,
        height: 10,
      ),
      Paint()..color = _ink.withValues(alpha: 0.12),
    );

    switch (obstacle.type) {
      case ObstacleType.spiral:
        canvas.drawCircle(
          Offset(centerX, centerY),
          obstacle.width / 2,
          Paint()..color = _obstacle,
        );
        final spiralPath = Path();
        for (var angle = 0.0; angle < pi * 4.2; angle += 0.16) {
          final radius = 2 + angle * 1.25;
          final point = Offset(
            centerX + cos(angle) * radius,
            centerY + sin(angle) * radius,
          );
          if (angle == 0) {
            spiralPath.moveTo(point.dx, point.dy);
          } else {
            spiralPath.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(
          spiralPath,
          Paint()
            ..color = _accentLight
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        break;
      case ObstacleType.stress:
        final barHeight = max(9.0, obstacle.height / 5);
        for (var index = 0; index < 3; index++) {
          final inset = index == 1 ? 0.0 : 7.0;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                x + inset,
                y + index * (barHeight + 6),
                obstacle.width - inset * 2,
                barHeight,
              ),
              const Radius.circular(7),
            ),
            Paint()..color = _obstacle,
          );
        }
        break;
      case ObstacleType.thought:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y + 5, obstacle.width, obstacle.height - 5),
            const Radius.circular(15),
          ),
          Paint()..color = _obstacle,
        );
        final knotPath = Path()
          ..moveTo(x + 8, centerY + 2)
          ..cubicTo(
            x + 14,
            centerY - 10,
            centerX - 5,
            centerY + 12,
            centerX,
            centerY,
          )
          ..cubicTo(
            centerX + 6,
            centerY - 12,
            x + obstacle.width - 14,
            centerY + 10,
            x + obstacle.width - 8,
            centerY - 2,
          );
        canvas.drawPath(
          knotPath,
          Paint()
            ..color = _accentLight
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        break;
    }

    final labelWidth = (obstacle.label.length * 6.4 + 22)
        .clamp(72.0, 118.0)
        .toDouble();
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, y - 18),
        width: labelWidth,
        height: 25,
      ),
      const Radius.circular(13),
    );
    canvas.drawRRect(
      labelRect,
      Paint()..color = _white.withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = _accentLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawText(
      canvas,
      obstacle.label,
      Offset(centerX, y - 18),
      color: _obstacleDark,
      fontSize: 11,
      bold: true,
      center: true,
    );
  }

  void _drawCollectible(Canvas canvas, Collectible collectible, int frame) {
    if (collectible.collected) return;
    final bob = reduceMotion ? 0.0 : sin(frame * 0.08 + collectible.x) * 4;
    final centerX = collectible.x;
    final centerY = collectible.y + bob;
    final color = switch (collectible.type) {
      CollectibleType.heart => _heart,
      CollectibleType.star => _star,
      CollectibleType.lotus => accent,
    };

    canvas.drawCircle(
      Offset(centerX, centerY),
      29,
      Paint()..color = color.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      Offset(centerX, centerY),
      20,
      Paint()..color = _white.withValues(alpha: 0.96),
    );

    switch (collectible.type) {
      case CollectibleType.heart:
        _drawHeart(canvas, centerX, centerY);
        break;
      case CollectibleType.star:
        _drawStar(canvas, centerX, centerY);
        break;
      case CollectibleType.lotus:
        _drawShield(canvas, centerX, centerY);
        break;
    }
  }

  void _drawHeart(Canvas canvas, double x, double y) {
    final path = Path()
      ..moveTo(x, y + 9)
      ..cubicTo(x - 15, y - 1, x - 14, y - 15, x, y - 8)
      ..cubicTo(x + 14, y - 15, x + 15, y - 1, x, y + 9);
    canvas.drawPath(path, Paint()..color = _heart);
  }

  void _drawStar(Canvas canvas, double centerX, double centerY) {
    var rotation = -pi / 2;
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final radius = index.isEven ? 13.0 : 6.0;
      final point = Offset(
        centerX + cos(rotation) * radius,
        centerY + sin(rotation) * radius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      rotation += pi / 5;
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _star);
  }

  void _drawShield(Canvas canvas, double centerX, double centerY) {
    final path = Path()
      ..moveTo(centerX, centerY - 14)
      ..lineTo(centerX + 13, centerY - 9)
      ..lineTo(centerX + 10, centerY + 7)
      ..quadraticBezierTo(centerX, centerY + 17, centerX, centerY + 17)
      ..quadraticBezierTo(centerX, centerY + 17, centerX - 10, centerY + 7)
      ..lineTo(centerX - 13, centerY - 9)
      ..close();
    canvas.drawPath(path, Paint()..color = accent);
    canvas.drawLine(
      Offset(centerX, centerY - 7),
      Offset(centerX, centerY + 9),
      Paint()
        ..color = _white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in engine.particles) {
      final sourceColor = Color(particle.colorValue);
      final displayColor = particle.colorValue == GameColors.shield
          ? accent
          : sourceColor;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        Paint()
          ..color = displayColor.withValues(
            alpha: (particle.life / particle.maxLife).clamp(0.0, 1.0),
          ),
      );
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final text in engine.floatingTexts) {
      _drawText(
        canvas,
        text.text,
        Offset(text.x, text.y),
        color: _ink.withValues(
          alpha: (text.life / text.maxLife).clamp(0.0, 1.0),
        ),
        fontSize: 17,
        bold: true,
        center: true,
      );
    }
  }

  void _drawAffirmation(Canvas canvas) {
    if (engine.affirmationTimer <= 0 || engine.affirmation.isEmpty) return;
    final timer = engine.affirmationTimer;
    final alpha = timer > 100
        ? (120 - timer) / 20
        : timer > 20
        ? 1.0
        : timer / 20;
    _drawText(
      canvas,
      engine.affirmation,
      const Offset(kCanvasW / 2, 88),
      color: _accentDark.withValues(alpha: alpha.clamp(0.0, 1.0)),
      fontSize: 24,
      bold: true,
      center: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    required Color color,
    required double fontSize,
    bool bold = false,
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = center
        ? Offset(
            position.dx - painter.width / 2,
            position.dy - painter.height / 2,
          )
        : position;
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant MindfulRunnerPainter oldDelegate) => true;
}
