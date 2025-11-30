part of 'auth_status_bloc.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthStatusState extends Equatable {
  final AuthStatus status;
  final UserEntity user;

  const AuthStatusState._({
    required this.status,
    this.user = UserEntity.empty,
  });

  const AuthStatusState.authenticated(UserEntity user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthStatusState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object> get props => [status, user];
}