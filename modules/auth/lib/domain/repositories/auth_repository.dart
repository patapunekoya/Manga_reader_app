import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity> get user;
  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  UserEntity get currentUser;
}