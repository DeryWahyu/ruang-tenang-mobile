import 'package:equatable/equatable.dart';

/// Statistik komunitas bulanan (paritas dengan web `GET /community/stats`).
///
/// Menggambarkan pencapaian agregat seluruh anggota pada periode berjalan:
/// total XP, anggota aktif, pencapaian, pertumbuhan, anggota baru, serta
/// jumlah kisah & artikel yang dipublikasikan.
class CommunityStats extends Equatable {
  final int totalXpEarned;
  final int activeMembers;
  final int totalAchievements;
  final double growthPercentage;
  final int newMembers;
  final int totalStoriesPublished;
  final int totalArticlesPublished;
  final int month;
  final int year;

  const CommunityStats({
    this.totalXpEarned = 0,
    this.activeMembers = 0,
    this.totalAchievements = 0,
    this.growthPercentage = 0,
    this.newMembers = 0,
    this.totalStoriesPublished = 0,
    this.totalArticlesPublished = 0,
    this.month = 0,
    this.year = 0,
  });

  @override
  List<Object?> get props => [
        totalXpEarned,
        activeMembers,
        totalAchievements,
        growthPercentage,
        newMembers,
        totalStoriesPublished,
        totalArticlesPublished,
        month,
        year,
      ];
}
