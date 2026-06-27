import '../../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<String> call({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) =>
      _repository.resetPassword(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
}
