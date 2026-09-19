import '../../domain/entities/secondary_gamification.dart';
import '../../core/utils/json_parser.dart';

// ==========================================
// XP Boost / Combo
// ==========================================
class XPBoostModel {
  static XPBoost fromJson(Map<String, dynamic> j) => XPBoost(
        id: Json.string(j['id']),
        multiplier: Json.doubleValue(j['multiplier']),
        triggerType: Json.string(j['trigger_type']),
        expiresAt: Json.date(j['expires_at']),
        remainingSeconds: Json.intValue(j['remaining_seconds']),
      );
}

class ComboStatusModel {
  static ComboStatus fromJson(Map<String, dynamic> j) => ComboStatus(
        comboCount: Json.intValue(j['combo_count']),
        multiplier: Json.doubleValue(j['multiplier']),
        nextMultiplier: Json.doubleValue(j['next_multiplier']),
        lastActivity: Json.string(j['last_activity']),
        expiresInSeconds: Json.intValue(j['expires_in_seconds']),
      );
}
