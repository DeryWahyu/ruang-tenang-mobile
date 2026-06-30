import '../entities/community.dart';

/// Kontrak repository untuk fitur Komunitas.
abstract class CommunityRepository {
  /// Statistik komunitas bulan berjalan.
  Future<CommunityStats> getStats();
}
