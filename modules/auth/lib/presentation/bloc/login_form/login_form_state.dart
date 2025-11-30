part of 'login_form_bloc.dart';

enum LoginFormStatus { initial, invalid, submitting, success, failure }
enum AuthMode { login, register }

class LoginFormState extends Equatable {
  final String email;
  final String password;
  final LoginFormStatus status;
  final AuthMode mode;
  final String? errorMessage;
  final bool isFormValid;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.status = LoginFormStatus.initial,
    this.mode = AuthMode.login,
    this.errorMessage,
    this.isFormValid = false,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    LoginFormStatus? status,
    AuthMode? mode,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [email, password, status, mode, errorMessage, isFormValid];
}