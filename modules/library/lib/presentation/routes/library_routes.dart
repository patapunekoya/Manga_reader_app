import 'package:flutter/material.dart';
import 'package:shared_dependencies/shared_dependencies.dart';
import '../pages/library_shell_page.dart';

class LibraryRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: '/library',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LibraryShellPage(),
      ),
    ),
  ];
}