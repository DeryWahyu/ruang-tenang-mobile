import '../../domain/entities/secondary_gamification.dart';
import '../../domain/repositories/secondary_gamification_repository.dart';
import '../datasources/remote/secondary_gamification_remote_datasource.dart';

class SecondaryGamificationRepositoryImpl implements SecondaryGamificationRepository {
  final SecondaryGamificationRemoteDataSource _remote;

  SecondaryGamificationRepositoryImpl({required SecondaryGamificationRemoteDataSource remote}) : _remote = remote;

  @override
  Future<XPBoost?> getActiveBoost() => _remote.getActiveBoost();

  @override
  Future<ComboStatus> getComboStatus() => _remote.getComboStatus();

  @override
  Future<double> getEffectiveMultiplier() => _remote.getEffectiveMultiplier();
}
