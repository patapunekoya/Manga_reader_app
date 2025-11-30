import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../application/sign_in_with_email.dart';
import '../../../application/sign_up_with_email.dart';
import '../../../domain/value_objects/email_address.dart'; // Dùng để validate
import '../../../domain/value_objects/password.dart'; // Dùng để validate

part 'login_form_event.dart';
part 'login_form_state.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  final SignInWithEmail _signIn;
  final SignUpWithEmail _signUp;

  LoginFormBloc({
    required SignInWithEmail signIn,
    required SignUpWithEmail signUp,
  })  : _signIn = signIn,
        _signUp = signUp,
        super(const LoginFormState()) {
    on<LoginFormEmailChanged>(_onEmailChanged);
    on<LoginFormPasswordChanged>(_onPasswordChanged);
    on<LoginFormSubmitted>(_onSubmitted);
    on<LoginFormToggleMode>(_onToggleMode);
  }

  void _onEmailChanged(LoginFormEmailChanged event, Emitter<LoginFormState> emit) {
    final newEmail = event.email;
    final isFormValid = _validateForm(newEmail, state.password);
    emit(state.copyWith(
      email: newEmail,
      isFormValid: isFormValid,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(LoginFormPasswordChanged event, Emitter<LoginFormState> emit) {
    final newPassword = event.password;
    final isFormValid = _validateForm(state.email, newPassword);
    emit(state.copyWith(
      password: newPassword,
      isFormValid: isFormValid,
      errorMessage: null,
    ));
  }

  // CẬP NHẬT: Xử lý chuyển đổi mode bằng tham số truyền vào
  void _onToggleMode(LoginFormToggleMode event, Emitter<LoginFormState> emit) {
    emit(state.copyWith(
      mode: event.mode, // Sử dụng mode mới truyền vào
      // Reset form khi chuyển mode
      email: '', 
      password: '',
      isFormValid: false,
      errorMessage: null,
      status: LoginFormStatus.initial,
    ));
  }

  bool _validateForm(String email, String password) {
    try {
      EmailAddress(email);
      Password(password);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onSubmitted(
      LoginFormSubmitted event, Emitter<LoginFormState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(status: LoginFormStatus.invalid));
      return;
    }

    emit(state.copyWith(status: LoginFormStatus.submitting, errorMessage: null));

    try {
      if (state.mode == AuthMode.login) {
        await _signIn(email: state.email, password: state.password);
      } else {
        await _signUp(email: state.email, password: state.password);
      }
      
      emit(state.copyWith(status: LoginFormStatus.success));
    } catch (e) {
      // Xử lý lỗi Firebase Auth (vd: invalid-credential, email-already-in-use)
      emit(state.copyWith(
          status: LoginFormStatus.failure, errorMessage: e.toString()));
    }
  }
}