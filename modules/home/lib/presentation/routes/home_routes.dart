import 'package:flutter/material.dart';
import 'package:shared_dependencies/shared_dependencies.dart';
// Di chuyển file home_shell_page.dart vào trong module home/presentation/pages/
import '../page/home_shell_page.dart'; 
// Hoặc nếu bạn giữ ở lib/page/ (không khuyến khích) thì import từ đó, nhưng đúng chuẩn là phải move vào module.

class HomeRoutes {
  static const String homePath = '/home';

  static List<GoRoute> get routes => [
    GoRoute(
      path: homePath,
      pageBuilder: (context, state) => const NoTransitionPage(
        // HomeShellPage giờ đây là 1 phần của module Home
        child: HomeShellPage(), 
      ),
    ),
  ];
}