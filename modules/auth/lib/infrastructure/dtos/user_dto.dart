import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

extension UserDto on firebase.User {
  UserEntity toDomain() {
    return UserEntity(id: uid, email: email ?? '');
  }
}