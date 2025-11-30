import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;

  const UserEntity({required this.id, required this.email});

  static const empty = UserEntity(id: '', email: '');

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  @override
  List<Object?> get props => [id, email];
}