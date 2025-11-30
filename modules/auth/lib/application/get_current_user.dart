// modules/auth/lib/application/get_current_user.dart
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repo;
  GetCurrentUser(this._repo);

  UserEntity call() => _repo.currentUser;
}