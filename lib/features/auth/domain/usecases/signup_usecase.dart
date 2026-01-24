import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<UserModel?> execute(String email, String password) {
    return _repository.signUp(email, password);
  }
}
