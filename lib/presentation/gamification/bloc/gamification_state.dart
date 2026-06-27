import 'package:equatable/equatable.dart';
import '../../../domain/entities/gamification.dart';

enum GamificationStatus { initial, loading, success, failure, submitting }

class GamificationState extends Equatable {
  final GamificationStatus status;
  final UserLevelInfo? levelInfo;
  final List<ExpHistory> expHistory;
  final List<BadgeProgress> badges;
  final List<MysteryChest> chests;
  final DailySpinWheel? spinWheel;
  final Map<String, dynamic>? openChestResult;
  final Map<String, dynamic>? spinResult;
  final String errorMessage;
  final String successMessage;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.levelInfo,
    this.expHistory = const [],
    this.badges = const [],
    this.chests = const [],
    this.spinWheel,
    this.openChestResult,
    this.spinResult,
    this.errorMessage = '',
    this.successMessage = '',
  });

  const GamificationState.initial() : this();

  GamificationState copyWith({
    GamificationStatus? status,
    UserLevelInfo? levelInfo,
    List<ExpHistory>? expHistory,
    List<BadgeProgress>? badges,
    List<MysteryChest>? chests,
    DailySpinWheel? spinWheel,
    Map<String, dynamic>? openChestResult,
    Map<String, dynamic>? spinResult,
    String? errorMessage,
    String? successMessage,
    bool clearResults = false,
  }) {
    return GamificationState(
      status: status ?? this.status,
      levelInfo: levelInfo ?? this.levelInfo,
      expHistory: expHistory ?? this.expHistory,
      badges: badges ?? this.badges,
      chests: chests ?? this.chests,
      spinWheel: spinWheel ?? this.spinWheel,
      openChestResult: clearResults ? null : (openChestResult ?? this.openChestResult),
      spinResult: clearResults ? null : (spinResult ?? this.spinResult),
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, levelInfo, expHistory, badges, chests, spinWheel,
    openChestResult, spinResult, errorMessage, successMessage
  ];
}