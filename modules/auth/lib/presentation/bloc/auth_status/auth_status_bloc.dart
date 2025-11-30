import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../application/stream_auth_status.dart';
import '../../../application/sign_out.dart';

part 'auth_status_event.dart';
part 'auth_status_state.dart';

class AuthStatusBloc extends Bloc<AuthStatusEvent, AuthStatusState> {
  final StreamAuthStatus _streamAuthStatus;
  final SignOut _signOut;
  late StreamSubscription<UserEntity> _userSubscription;

  AuthStatusBloc({
    required StreamAuthStatus streamAuthStatus,
    required SignOut signOut,
  })  : _streamAuthStatus = streamAuthStatus,
        _signOut = signOut,
        super(const AuthStatusState.unauthenticated()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _userSubscription = _streamAuthStatus().listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  void _onAuthStatusChanged(
      AuthStatusChanged event, Emitter<AuthStatusState> emit) {
    emit(event.user.isNotEmpty
        ? AuthStatusState.authenticated(event.user)
        : const AuthStatusState.unauthenticated());
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthStatusState> emit) {
    _signOut();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}