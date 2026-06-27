import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Checks the persisted auth status and returns the cached user (if any).
///
/// Returns `null` when there is no token / no cached user, meaning the
/// user is unauthenticated. Profile refresh from the network is handled
/// separately by the BLoC (background) so this stays fast.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  CheckAuthStatusUseCase(this._repository);

  Future<User?> call() async {
    final isAuth = await _repository.isAuthenticated();
    if (!isAuth) return null;
    return _repository.getCachedUser();
  }
}
