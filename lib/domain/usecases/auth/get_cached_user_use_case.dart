import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCachedUserUseCase {
  final AuthRepository _repository;
  GetCachedUserUseCase(this._repository);

  Future<User?> call() => _repository.getCachedUser();
}
