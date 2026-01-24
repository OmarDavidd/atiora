import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';

class SignoutUseCase {
  final AuthRepository _repository;
  SignoutUseCase(this._repository);

  Future<void> execute() {
    return _repository.signOut();
  }
}
