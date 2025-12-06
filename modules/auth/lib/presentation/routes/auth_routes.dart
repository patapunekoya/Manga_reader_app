import 'package:flutter/material.dart';
import 'package:shared_dependencies/shared_dependencies.dart';
import '../pages/login_page.dart';
import '../pages/profile_shell_page.dart'; // Import trang profile vừa move vào

class AuthRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(), // LoginPage tự handle switch mode
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProfileShellPage(),
      ),
    ),
  ];
}