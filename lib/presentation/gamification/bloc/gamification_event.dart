import 'package:equatable/equatable.dart';

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();
  @override
  List<Object?> get props => [];
}

class GamificationLevelRequested extends GamificationEvent {
  const GamificationLevelRequested();
}

class GamificationExpHistoryRequested extends GamificationEvent {
  final bool refresh;
  const GamificationExpHistoryRequested({this.refresh = false});
  @override
  List<Object?> get props => [refresh];
}

class GamificationBadgesRequested extends GamificationEvent {
  const GamificationBadgesRequested();
}

class GamificationChestsRequested extends GamificationEvent {
  const GamificationChestsRequested();
}

class GamificationChestOpened extends GamificationEvent {
  final String chestId;
  const GamificationChestOpened(this.chestId);
  @override
  List<Object?> get props => [chestId];
}

class GamificationSpinWheelRequested extends GamificationEvent {
  const GamificationSpinWheelRequested();
}

class GamificationSpinRequested extends GamificationEvent {
  const GamificationSpinRequested();
}