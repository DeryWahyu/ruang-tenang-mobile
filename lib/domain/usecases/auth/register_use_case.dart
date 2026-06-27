import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) =>
      _repository.register(name: name, email: email, password: password);
}
