import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // THÊM: Import GoRouter để điều hướng

// THÊM: Import Core để lấy AppColors cho đồng bộ
import 'package:core/core.dart';

import 'package:shared_dependencies/shared_dependencies.dart';

// Import BLoC và UseCase từ module auth
import '../bloc/login_form/login_form_bloc.dart';
// ======================================================================
// LoginPage: Entry point, cung cấp Bloc
// ======================================================================
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp LoginFormBloc cho cây widget con
    return BlocProvider(
      create: (_) => GetIt.instance<LoginFormBloc>(),
      // Sử dụng AuthFormContent để hiển thị Form
      // (Đã sửa tên từ _LoginPageContent thành AuthFormContent trong bước trước)
      child: const AuthFormContent(), 
    );
  }
}


// ======================================================================
// AuthFormContent: Widget Public chứa logic Form UI
// (Sửa tên từ _LoginPageContent)
// ======================================================================
class AuthFormContent extends StatefulWidget { 
  const AuthFormContent(); 

  @override
  State<AuthFormContent> createState() => _AuthFormContentState();
}

class _AuthFormContentState extends State<AuthFormContent> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // Bắt đầu lắng nghe thay đổi của TextField để bắn Event vào Bloc
  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    context.read<LoginFormBloc>().add(LoginFormEmailChanged(_emailController.text));
  }

  void _onPasswordChanged() {
    context.read<LoginFormBloc>().add(LoginFormPasswordChanged(_passController.text));
  }

  // Chức năng submission giờ chỉ cần bắn event
  void _submit() {
    context.read<LoginFormBloc>().add(const LoginFormSubmitted());
  }
  
  // Chuyển đổi giữa Login và Register
  void _toggleMode(AuthMode currentMode) {
    final newMode = currentMode == AuthMode.login ? AuthMode.register : AuthMode.login;
    context.read<LoginFormBloc>().add(LoginFormToggleMode(newMode));
    
    // Reset controllers và focus sau khi chuyển mode
    _emailController.clear();
    _passController.clear();
  }
  // HÀM XỬ LÝ NÚT BACK
  void _handleBack() {
    // Nếu có thể pop (ví dụ từ Library -> Login), thì pop về trang trước
    if (context.canPop()) {
      context.pop();
    } else {
      // Nếu không (ví dụ mở app vào thẳng Login), thì về Home
      context.go('/home');
    }
  }


  @override
  Widget build(BuildContext context) {
    // BlocConsumer để vừa lắng nghe lỗi, vừa rebuild UI
    return BlocConsumer<LoginFormBloc, LoginFormState>(
      listener: (context, state) {
        // Lắng nghe lỗi Firebase và hiển thị SnackBar
        if (state.status == LoginFormStatus.failure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Lỗi: ${state.errorMessage ?? 'Không xác định'}")));
        }
        // Khi thành công, AuthStatusBloc sẽ tự lo chuyển màn hình
      },
      builder: (context, state) {
        final isLogin = state.mode == AuthMode.login;
        final isLoading = state.status == LoginFormStatus.submitting;
        final isInvalid = state.status == LoginFormStatus.invalid; // Dùng để highlight lỗi
        
        return Scaffold(
          backgroundColor: Colors.black, // Theme tối
          // --- THÊM PHẦN APP BAR (HEADER) ---
          appBar: AppBar(
            backgroundColor: AppColors.background, // Màu nền giống background app
            elevation: 0, // Không đổ bóng
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _handleBack, // Gọi hàm quay lại
              tooltip: 'Về trang chủ',
            ),
          ),


          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? "Đăng Nhập" : "Đăng Ký",
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                ),
                const SizedBox(height: 32),
                
                // TextField Email
                TextField(
                  controller: _emailController,
                  onChanged: (val) {}, // Không dùng onChanged ở đây vì dùng listener
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    // Có thể thêm errorText: isInvalid ? 'Email không hợp lệ' : null
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // TextField Mật khẩu
                TextField(
                  controller: _passController,
                  onChanged: (val) {}, // Không dùng onChanged ở đây
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Nút Submit
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    // Kích hoạt nút chỉ khi form hợp lệ (isFormValid từ state)
                    onPressed: state.isFormValid ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(isLogin ? "Vào đọc truyện" : "Tạo tài khoản"),
                  ),
                
                // Nút Toggle Mode
                TextButton(
                  onPressed: () => _toggleMode(state.mode),
                  child: Text(
                    isLogin ? "Chưa có tài khoản? Đăng ký" : "Đã có tài khoản? Đăng nhập",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}