import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';
import '../dtos/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDS;

  AuthRepositoryImpl(this._remoteDS);

  @override
  Stream<UserEntity> get user {
    return _remoteDS.authStateChanges.map((firebaseUser) {
      return firebaseUser == null ? UserEntity.empty : firebaseUser.toDomain();
    });
  }

  @override
  UserEntity get currentUser {
    final user = _remoteDS.currentUser;
    return user == null ? UserEntity.empty : user.toDomain();
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _remoteDS.signIn(email, password);
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _remoteDS.signUp(email, password);
  }

  @override
  Future<void> signOut() {
    return _remoteDS.signOut();
  }
}