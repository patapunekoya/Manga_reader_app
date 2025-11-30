part of 'login_form_bloc.dart';

abstract class LoginFormEvent extends Equatable {
  const LoginFormEvent();
  @override
  List<Object> get props => [];
}

class LoginFormEmailChanged extends LoginFormEvent {
  final String email;
  const LoginFormEmailChanged(this.email);
  @override
  List<Object> get props => [email];
}

class LoginFormPasswordChanged extends LoginFormEvent {
  final String password;
  const LoginFormPasswordChanged(this.password);
  @override
  List<Object> get props => [password];
}

class LoginFormSubmitted extends LoginFormEvent {
  const LoginFormSubmitted();
}

// CẬP NHẬT: Thêm tham số mode để chuyển đổi chính xác
class LoginFormToggleMode extends LoginFormEvent {
  final AuthMode mode;
  const LoginFormToggleMode(this.mode);
  @override
  List<Object> get props => [mode];
}