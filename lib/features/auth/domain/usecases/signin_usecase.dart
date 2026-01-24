import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<UserModel?> execute(String email, String password) {
    return _repository.signIn(email, password);
  }
}
