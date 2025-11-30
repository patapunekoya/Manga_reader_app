// modules/auth/lib/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/login_form/login_form_bloc.dart';
import 'login_page.dart'; // Giả định _LoginPageContent hoặc UI được tái sử dụng từ đây

/// RegisterPage
/// Entry point cho tính năng đăng ký (Register).
/// File này đảm bảo LoginFormBloc được khởi tạo với chế độ Đăng Ký (Register Mode).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Lấy LoginFormBloc từ DI
      create: (context) {
        final bloc = GetIt.instance<LoginFormBloc>();
        
        // BẮT BUỘC: Đảm bảo BLoC khởi động ở chế độ Đăng ký 
        // (Giả định LoginFormToggleMode đã được cập nhật để nhận AuthMode)
        bloc.add(const LoginFormToggleMode(AuthMode.register)); 
        return bloc;
      },
      // Tái sử dụng Widget hiển thị Form chung
      // (Giả sử form UI chính được định nghĩa trong _LoginPageContent)
      child: const AuthFormContent(), 
    );
  }
}

// Note: Bạn cần đảm bảo đã cập nhật các file BLoC sau:
// 1. login_form_event.dart: Thêm tham số 'mode' vào LoginFormToggleMode.
// 2. login_form_bloc.dart: Cập nhật _onToggleMode để sử dụng tham số 'mode' truyền vào.