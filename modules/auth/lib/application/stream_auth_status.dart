import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

class StreamAuthStatus {
  final AuthRepository _repo;
  StreamAuthStatus(this._repo);

  Stream<UserEntity> call() => _repo.user;
}