import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_dependencies/shared_dependencies.dart';
import 'package:auth/auth.dart'; // Import Auth Module
import 'package:core/core.dart'; // <--- SỬA: Lấy AppColors từ Core

/// ProfileShellPage
/// Màn hình Tài khoản: chứa nút Đăng nhập/Đăng xuất
class ProfileShellPage extends StatelessWidget {
  const ProfileShellPage({super.key});
  
  void _handleLogout(BuildContext context) {
    // Kích hoạt event Log out
    context.read<AuthStatusBloc>().add(AuthLogoutRequested());
  }
  
  void _handleLogin(BuildContext context) {
    // Chuyển hướng tới trang Đăng nhập
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái AuthStatusBloc
    final authState = context.watch<AuthStatusBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAuthenticated) ...[
                Text(
                  'Xin chào, ${authState.user.email}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ] else ...[
                const Text(
                  'Bạn chưa đăng nhập.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _handleLogin(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Đăng nhập / Đăng ký'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 241, 241),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}