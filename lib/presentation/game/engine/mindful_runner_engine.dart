// Engine logika untuk mini game **Mindful Runner** (offline).
//
// Meniru mekanik versi web: endless runner ala "dino jump" — pemain berlari
// otomatis, melompati rintangan "pikiran negatif", dan mengumpulkan
// hati/bintang/lotus untuk poin + combo. Seluruh logika di sini **murni
// Dart** (tanpa Flutter) agar mudah diuji & dipisah dari rendering.
//
// Sistem koordinat memakai kanvas logis 1400×420 (sama seperti web); layar
// menskalakan kanvas ini agar pas di perangkat.
import 'dart:math';

// ——— Konstanta dunia (selaras web, disempurnakan) ———
const double kCanvasW = 800;
const double kCanvasH = 1000;
const double kGroundY = 750;
const double kGravity = 0.6;
const double kJumpForce = -11;
const double kInitialSpeed = 4;
const double kMaxSpeed = 10;
const double kSpeedIncrement = 0.001;
const double kDifficultyTierScore = 500;
const double kDifficultyScalePerTier = 0.3;

// Fisika lompat yang lebih kaya:
// - Variable jump: menahan tombol saat naik mengurangi gravitasi → lompat
//   lebih tinggi; melepas tombol mempercepat turun (terasa responsif).
const double kJumpHoldGravityMult = 0.45; // gravitasi saat naik & ditahan
const double kFastFallGravityMult = 1.6;   // gravitasi turun saat tidak ditahan
const double kDoubleJumpForce = -9.5;      // dorongan lompatan kedua
const int kCoyoteFrames = 6;               // toleransi lompat sesaat setelah jatuh
const int kMaxJumps = 2;                   // lompatan ganda (1 lompatan udara)

// Power-up & bonus
const int kShieldDurationFrames = 600;     // ~10 detik perisai dari lotus
const double kNearMissDistance = 14;       // jarak "nyaris" untuk bonus

enum GameStatus { idle, playing, over }

enum ObstacleType { thought, stress, spiral }

enum CollectibleType { heart, star, lotus }

const List<String> kObstacleLabels = [
  'Overthinking', 'Cemas', 'Stres', 'Panik', 'Takut',
  'Sedih', 'Marah', 'Insomnia', 'Lelah', 'Ragu',
];

const List<String> kPlayAffirmations = [
  'Kamu hebat!', 'Tetap tenang', 'Terus melangkah', 'Kamu berharga',
  'Hari ini indah', 'Napas dalam...', 'Kamu kuat', 'Semangat!',
];

const List<String> kGameOverMessages = [
  'Setiap langkah kecil tetap berarti',
  'Istirahat juga bagian dari perjalanan',
  'Kamu sudah berusaha dengan baik hari ini',
  'Jatuh bukan berarti gagal, coba lagi ya',
  'Kamu lebih kuat dari yang kamu kira',
  'Tidak apa-apa, ambil napas dan coba lagi',
  'Semangat! Ketenangan ada di setiap langkah',
  'Perjalananmu unik dan berharga',
];

class Obstacle {
  double x;
  final double width;
  final double height;
  final ObstacleType type;
  final String label;
  bool nearMissScored; // sudah diberi bonus "nyaris"?
  bool passed; // sudah dilewati pemain?
  Obstacle({
    required this.x,
    required this.width,
    required this.height,
    required this.type,
    required this.label,
    this.nearMissScored = false,
    this.passed = false,
  });
}

class Collectible {
  double x;
  final double y;
  final CollectibleType type;
  bool collected;
  Collectible({required this.x, required this.y, required this.type, this.collected = false});
}

class Cloud {
  double x;
  final double y;
  final double width;
  final double speed;
  Cloud({required this.x, required this.y, required this.width, required this.speed});
}

class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  double life;
  final double maxLife;
  final int colorValue;
  final double size;
  Particle({
    required this.x, required this.y, required this.vx, required this.vy,
    required this.life, required this.maxLife, required this.colorValue, required this.size,
  });
}

class FloatingText {
  final double x;
  double y;
  final String text;
  double life;
  final double maxLife;
  FloatingText({required this.x, required this.y, required this.text, required this.life, required this.maxLife});
}

/// Hasil satu langkah update — dipakai screen untuk efek (shake) & SFX/haptic.
class StepResult {
  final bool collided;
  final bool collected;
  const StepResult({this.collided = false, this.collected = false});
}

/// Warna entitas (sebagai int ARGB) agar engine tetap bebas-Flutter.
class GameColors {
  static const int player = 0xFFEF4444;
  static const int obstacleDark = 0xFF374151;
  static const int heart = 0xFFEF4444;
  static const int star = 0xFFFBBF24;
  static const int flower = 0xFFF472B6;
  static const int gray = 0xFF9CA3AF;
}

/// Status & logika dunia game. Pemanggil memanggil [start] lalu [step] tiap
/// frame, dan [jump] saat input.
class MindfulRunnerEngine {
  final Random _rng = Random();

  GameStatus status = GameStatus.idle;
  int score = 0;
  int highScore = 0;
  double speed = kInitialSpeed;

  // Player
  double playerY = kGroundY;
  double playerVelocity = 0;
  bool isJumping = false;
  int playerFrame = 0;
  int frameCount = 0;

  // Lompat lanjutan
  bool jumpHeld = false;   // tombol sedang ditahan (variable jump)
  int jumpsUsed = 0;       // jumlah lompatan sejak menapak (utk double jump)
  int coyoteCounter = 0;   // sisa frame "coyote time"

  // Power-up perisai (dari lotus): menyerap satu tabrakan.
  int shieldFrames = 0;
  bool get hasShield => shieldFrames > 0;

  // Entities
  final List<Obstacle> obstacles = [];
  final List<Collectible> collectibles = [];
  final List<Cloud> clouds = [];
  final List<Particle> particles = [];
  final List<FloatingText> floatingTexts = [];

  // Timing/spawn
  double _obstacleTravel = 0;
  double _collectibleTravel = 0;
  double _nextObstacleGap = 0;
  double _nextCollectibleGap = 0;

  // Affirmation
  String affirmation = '';
  int affirmationTimer = 0;

  // Combo & screen shake
  int combo = 0;
  int collected = 0;
  double shakeX = 0;
  double shakeY = 0;
  int shakeLife = 0;

  String overMessage = '';

  double _randObstacleGap() => 180 + _rng.nextDouble() * 200;
  double _randCollectibleGap() => 250 + _rng.nextDouble() * 300;

  void start() {
    status = GameStatus.playing;
    score = 0;
    speed = kInitialSpeed;
    playerY = kGroundY;
    playerVelocity = 0;
    isJumping = false;
    playerFrame = 0;
    frameCount = 0;
    jumpHeld = false;
    jumpsUsed = 0;
    coyoteCounter = 0;
    shieldFrames = 0;
    obstacles.clear();
    collectibles.clear();
    clouds
      ..clear()
      ..addAll([
        Cloud(x: 100, y: 80, width: 60, speed: 0.4),
        Cloud(x: 350, y: 50, width: 80, speed: 0.3),
        Cloud(x: 600, y: 110, width: 50, speed: 0.5),
      ]);
    particles.clear();
    floatingTexts.clear();
    _obstacleTravel = 0;
    _collectibleTravel = 120;
    _nextObstacleGap = _randObstacleGap();
    _nextCollectibleGap = _randCollectibleGap();
    affirmation = '';
    affirmationTimer = 0;
    combo = 0;
    collected = 0;
    shakeX = 0;
    shakeY = 0;
    shakeLife = 0;
    overMessage = '';
  }

  /// Mulai lompatan. Mendukung:
  /// - lompat dari tanah (atau dalam masa "coyote time" sesaat setelah jatuh),
  /// - **double jump**: satu lompatan tambahan saat di udara.
  void jump() {
    if (status != GameStatus.playing) return;
    final onGroundish = !isJumping || coyoteCounter > 0;

    if (onGroundish && jumpsUsed == 0) {
      isJumping = true;
      jumpHeld = true;
      jumpsUsed = 1;
      coyoteCounter = 0;
      playerVelocity = kJumpForce;
    } else if (jumpsUsed < kMaxJumps) {
      // Lompatan kedua (di udara) — dorongan sedikit lebih kecil.
      jumpHeld = true;
      jumpsUsed++;
      playerVelocity = kDoubleJumpForce;
    }
  }

  /// Lepas tombol lompat → menghentikan "variable jump" sehingga karakter
  /// mulai turun lebih cepat (kontrol tinggi lompatan terasa responsif).
  void releaseJump() {
    jumpHeld = false;
  }

  /// Maju satu frame. Mengembalikan [StepResult]; saat `collided` true,
  /// status berubah ke [GameStatus.over] dan pemanggil menyimpan high score.
  StepResult step() {
    if (status != GameStatus.playing) return const StepResult();
    frameCount++;

    // Kecepatan naik bertahap, makin cepat tiap tier skor.
    final tier = (score / kDifficultyTierScore).floor();
    final inc = kSpeedIncrement * (1 + tier * kDifficultyScalePerTier);
    speed = min(kMaxSpeed, speed + inc);

    // Player fisika lompat — gravitasi adaptif (variable jump & fast-fall).
    if (isJumping) {
      double g = kGravity;
      if (playerVelocity < 0) {
        // Sedang naik: tahan tombol → naik lebih tinggi (gravitasi kecil).
        g = jumpHeld ? kGravity * kJumpHoldGravityMult : kGravity;
      } else {
        // Sedang turun: lebih cepat bila tombol dilepas (terasa snappy).
        g = jumpHeld ? kGravity : kGravity * kFastFallGravityMult;
      }
      playerVelocity += g;
      playerY += playerVelocity;
      if (playerY >= kGroundY) {
        playerY = kGroundY;
        isJumping = false;
        playerVelocity = 0;
        jumpsUsed = 0;
        coyoteCounter = kCoyoteFrames; // beri toleransi lompat sesaat
      }
    } else if (coyoteCounter > 0) {
      coyoteCounter--;
    }

    // Perisai meluruh tiap frame.
    if (shieldFrames > 0) shieldFrames--;
    playerFrame++;

    _obstacleTravel += speed;
    _collectibleTravel += speed;

    // Spawn obstacle
    if (_obstacleTravel >= _nextObstacleGap) {
      final type = ObstacleType.values[_rng.nextInt(ObstacleType.values.length)];
      final w = type == ObstacleType.spiral ? 40.0 : 40 + _rng.nextDouble() * 30;
      final h = type == ObstacleType.stress ? 60 + _rng.nextDouble() * 20 : 40 + _rng.nextDouble() * 30;
      obstacles.add(Obstacle(
        x: kCanvasW + 20, width: w, height: h, type: type,
        label: kObstacleLabels[_rng.nextInt(kObstacleLabels.length)],
      ));
      _obstacleTravel = 0;
      _nextObstacleGap = _randObstacleGap();
    }

    // Spawn collectible
    if (_collectibleTravel >= _nextCollectibleGap) {
      collectibles.add(Collectible(
        x: kCanvasW + 20,
        y: kGroundY - 20 - _rng.nextDouble() * 60,
        type: CollectibleType.values[_rng.nextInt(CollectibleType.values.length)],
      ));
      _collectibleTravel = 0;
      _nextCollectibleGap = _randCollectibleGap();
    }

    // Spawn cloud
    if (clouds.length < 4 && _rng.nextDouble() < 0.005) {
      clouds.add(Cloud(
        x: kCanvasW + 50, y: 20 + _rng.nextDouble() * 60,
        width: 40 + _rng.nextDouble() * 60, speed: 0.3 + _rng.nextDouble() * 0.5,
      ));
    }

    // Update obstacles
    for (var i = obstacles.length - 1; i >= 0; i--) {
      obstacles[i].x -= speed;
      if (obstacles[i].x + obstacles[i].width < -20) {
        obstacles.removeAt(i);
        score += 1;
      }
    }

    // Update collectibles (combo reset bila terlewat)
    for (var i = collectibles.length - 1; i >= 0; i--) {
      final c = collectibles[i];
      c.x -= speed;
      if (c.x < -20) {
        if (!c.collected) combo = 0;
        collectibles.removeAt(i);
      }
    }

    // Update clouds
    for (var i = clouds.length - 1; i >= 0; i--) {
      clouds[i].x -= clouds[i].speed;
      if (clouds[i].x + clouds[i].width < -10) clouds.removeAt(i);
    }

    // Update particles
    for (var i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.life--;
      if (p.life <= 0) particles.removeAt(i);
    }

    // Update floating texts
    for (var i = floatingTexts.length - 1; i >= 0; i--) {
      final ft = floatingTexts[i];
      ft.y -= 0.8;
      ft.life--;
      if (ft.life <= 0) floatingTexts.removeAt(i);
    }

    // Affirmation
    if (affirmationTimer > 0) {
      affirmationTimer--;
    } else if (_rng.nextDouble() < 0.002 && score > 5) {
      affirmation = kPlayAffirmations[_rng.nextInt(kPlayAffirmations.length)];
      affirmationTimer = 120;
    }

    // Collision: obstacles (AABB dgn sedikit toleransi seperti web)
    bool collided = false;
    double colX = 0, colY = 0;
    final pBox = _Rect(52, playerY - 48, 30, 72);
    for (final obs in obstacles) {
      final oBox = _Rect(obs.x, kGroundY + 24 - obs.height, obs.width, obs.height);
      final hit = pBox.x < oBox.x + oBox.w - 4 &&
          pBox.x + pBox.w > oBox.x + 4 &&
          pBox.y + pBox.h > oBox.y + 4 &&
          pBox.y < oBox.y + oBox.h - 4;
      if (hit) {
        collided = true;
        colX = oBox.x + oBox.w / 2;
        colY = oBox.y + oBox.h / 2;
        break;
      }

      // Near-miss: berhasil melompati rintangan dengan jarak tipis → bonus.
      if (!obs.passed && oBox.x + oBox.w < pBox.x) {
        obs.passed = true;
        final gap = (pBox.y + pBox.h) - oBox.y; // seberapa "nyaris" di atasnya
        if (!obs.nearMissScored && gap > 0 && gap < kNearMissDistance + 12 && isJumping) {
          obs.nearMissScored = true;
          score += 5;
          combo = min(combo + 1, 5);
          floatingTexts.add(FloatingText(
            x: pBox.x, y: pBox.y - 6, text: 'Nyaris! +5', life: 45, maxLife: 45,
          ));
        }
      }
    }

    if (collided) {
      // Perisai aktif → serap satu tabrakan, jangan game over.
      if (hasShield) {
        shieldFrames = 0;
        shakeLife = 6;
        // Singkirkan rintangan yang mengenai agar tidak langsung memukul lagi.
        obstacles.removeWhere((o) {
          final ox = o.x;
          return ox < 110 && ox + o.width > 40;
        });
        for (var i = 0; i < 16; i++) {
          particles.add(Particle(
            x: colX, y: colY,
            vx: (_rng.nextDouble() - 0.5) * 8, vy: (_rng.nextDouble() - 0.5) * 6,
            life: 18 + _rng.nextDouble() * 12, maxLife: 30,
            colorValue: GameColors.flower, size: 2 + _rng.nextDouble() * 3,
          ));
        }
        floatingTexts.add(FloatingText(
          x: colX, y: colY - 10, text: 'Perisai!', life: 45, maxLife: 45,
        ));
        collided = false; // batalkan tabrakan
      } else {
        shakeLife = 8;
        for (var i = 0; i < 14; i++) {
          particles.add(Particle(
            x: colX, y: colY,
            vx: (_rng.nextDouble() - 0.5) * 7, vy: (_rng.nextDouble() - 0.5) * 5,
            life: 16 + _rng.nextDouble() * 10, maxLife: 26,
            colorValue: i.isEven ? GameColors.player : GameColors.obstacleDark,
            size: 2 + _rng.nextDouble() * 3,
          ));
        }
        _endGame();
        return const StepResult(collided: true);
      }
    }

    // Collision: collectibles
    bool gotCollectible = false;
    for (final c in collectibles) {
      if (c.collected) continue;
      final dx = 72 - c.x;
      final dy = playerY - 14 - c.y;
      if (sqrt(dx * dx + dy * dy) < 22) {
        c.collected = true;
        gotCollectible = true;
        collected++;
        combo++;
        final bonus = c.type == CollectibleType.lotus ? 5 : c.type == CollectibleType.star ? 3 : 2;
        score += bonus * min(combo, 5);
        // Lotus memberi perisai pelindung (menyerap satu tabrakan).
        if (c.type == CollectibleType.lotus) {
          shieldFrames = kShieldDurationFrames;
          floatingTexts.add(FloatingText(
            x: c.x, y: c.y - 24, text: 'Perisai aktif', life: 50, maxLife: 50,
          ));
        }
        final colorVal = c.type == CollectibleType.heart
            ? GameColors.heart
            : c.type == CollectibleType.star
                ? GameColors.star
                : GameColors.flower;
        for (var i = 0; i < 8; i++) {
          particles.add(Particle(
            x: c.x, y: c.y,
            vx: (_rng.nextDouble() - 0.5) * 4, vy: (_rng.nextDouble() - 0.5) * 4,
            life: 20 + _rng.nextDouble() * 15, maxLife: 35,
            colorValue: colorVal, size: 2 + _rng.nextDouble() * 3,
          ));
        }
        floatingTexts.add(FloatingText(
          x: c.x, y: c.y - 10,
          text: '+${bonus * min(combo, 5)}', life: 40, maxLife: 40,
        ));
      }
    }

    // Score tick
    if (frameCount % 8 == 0) score++;

    // Screen shake decay
    if (shakeLife > 0) {
      shakeLife--;
      shakeX = (_rng.nextDouble() - 0.5) * 8;
      shakeY = (_rng.nextDouble() - 0.5) * 4;
    } else {
      shakeX = 0;
      shakeY = 0;
    }

    return StepResult(collected: gotCollectible);
  }

  void _endGame() {
    status = GameStatus.over;
    if (score > highScore) highScore = score;
    overMessage = kGameOverMessages[_rng.nextInt(kGameOverMessages.length)];
  }
}

class _Rect {
  final double x, y, w, h;
  const _Rect(this.x, this.y, this.w, this.h);
}
