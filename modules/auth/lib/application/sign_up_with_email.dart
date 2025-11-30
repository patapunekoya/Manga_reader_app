import '../domain/repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository _repo;
  SignUpWithEmail(this._repo);

  Future<void> call({required String email, required String password}) {
    return _repo.signUp(email: email, password: password);
  }
}