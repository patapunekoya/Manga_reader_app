import '../domain/repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repo;
  SignInWithEmail(this._repo);

  Future<void> call({required String email, required String password}) {
    return _repo.signIn(email: email, password: password);
  }
}