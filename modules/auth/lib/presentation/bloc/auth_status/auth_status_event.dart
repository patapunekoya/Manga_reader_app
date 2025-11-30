part of 'auth_status_bloc.dart';

abstract class AuthStatusEvent extends Equatable {
  const AuthStatusEvent();
  @override
  List<Object> get props => [];
}

class AuthStatusChanged extends AuthStatusEvent {
  final UserEntity user;
  const AuthStatusChanged(this.user);
  @override
  List<Object> get props => [user];
}

class AuthLogoutRequested extends AuthStatusEvent {}