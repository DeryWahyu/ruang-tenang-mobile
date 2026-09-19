import '../entities/secondary_gamification.dart';

abstract class SecondaryGamificationRepository {
  // XP Boost / Combo
  Future<XPBoost?> getActiveBoost();
  Future<ComboStatus> getComboStatus();
  Future<double> getEffectiveMultiplier();
}
