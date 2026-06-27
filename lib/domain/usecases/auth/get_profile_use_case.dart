import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository _repository;
  GetProfileUseCase(this._repository);

  Future<User> call() => _repository.getProfile();
}
