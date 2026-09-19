import 'package:equatable/equatable.dart';

// ==========================================
// XP Boost / Combo
// ==========================================
class XPBoost extends Equatable {
  final String id;
  final double multiplier;
  final String triggerType;
  final DateTime? expiresAt;
  final int remainingSeconds;

  const XPBoost({
    required this.id,
    required this.multiplier,
    required this.triggerType,
    required this.expiresAt,
    required this.remainingSeconds,
  });

  @override
  List<Object?> get props => [id, multiplier, triggerType, expiresAt, remainingSeconds];
}

class ComboStatus extends Equatable {
  final int comboCount;
  final double multiplier;
  final double nextMultiplier;
  final String lastActivity;
  final int expiresInSeconds;

  const ComboStatus({
    required this.comboCount,
    required this.multiplier,
    required this.nextMultiplier,
    required this.lastActivity,
    required this.expiresInSeconds,
  });

  @override
  List<Object?> get props => [comboCount, multiplier, nextMultiplier, lastActivity, expiresInSeconds];
}

/// Aggregate for the XP Boost & Combo screen.
class XpBoostData extends Equatable {
  final XPBoost? boost;
  final ComboStatus combo;
  final double effectiveMultiplier;

  const XpBoostData({required this.boost, required this.combo, required this.effectiveMultiplier});

  @override
  List<Object?> get props => [boost, combo, effectiveMultiplier];
}
