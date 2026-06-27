import '../../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;
  ForgotPasswordUseCase(this._repository);

  Future<String> call({required String email}) =>
      _repository.forgotPassword(email: email);
}
