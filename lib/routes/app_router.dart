import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

// Import Auth Module
import 'package:auth/auth.dart'; 
import 'package:auth/auth_module.dart';

// Import các Module khác
import 'package:home/home_module.dart';
import 'package:catalog/catalog_module.dart';
import 'package:library_manga/library_module.dart';
import 'package:reader/reader_module.dart';

// Import trang chi tiết
import 'package:catalog/presentation/pages/manga_detail_shell_page.dart';
import 'package:reader/presentation/page/reader_shell_page.dart';
import '../page/main_shell.dart'; 

/// Class tiện ích: Chuyển đổi Stream (của Bloc) thành Listenable (cho GoRouter)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter();

  late final GoRouter config = GoRouter(
    // FIX QUAN TRỌNG: Bọc AuthStatusBloc.stream vào GoRouterRefreshStream
    refreshListenable: GoRouterRefreshStream(GetIt.instance<AuthStatusBloc>().stream),
    
    initialLocation: '/home',
    
    routes: [
      // ... (Giữ nguyên các route như cũ)
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 0),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 1),
        ),
      ),
      GoRoute(
        path: '/library',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 2),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 3),
        ),
      ),
      
      ...AuthModule.routes,

      GoRoute(
        path: '/manga/:mangaId',
        pageBuilder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          final origin = (state.uri.queryParameters['from'] ?? 'home').toLowerCase();
          final resumeChapterId = state.uri.queryParameters['resume_chapter'];

          return CustomTransitionPage(
            child: MangaDetailShellPage(
              mangaId: mangaId, 
              origin: origin,
              resumeChapterId: resumeChapterId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/reader/:chapterId',
        pageBuilder: (context, state) {
           final chapterId = state.pathParameters['chapterId'] ?? '';
           final mangaId = state.uri.queryParameters['mangaId'] ?? '';
           final mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
           final coverImageUrl = state.uri.queryParameters['coverImageUrl'];
           
           final extra = state.extra as Map<String, dynamic>?;
           final chapters = (extra?['chapters'] is List) ? List<String>.from(extra!['chapters']) : [chapterId];
           final chapterNumbers = (extra?['chapterNumbers'] is List) 
               ? (extra!['chapterNumbers'] as List).map((e) => e.toString()).toList() 
               : null;
           int currentIndex = (extra?['currentIndex'] is int) ? extra!['currentIndex'] : 0;

           return CustomTransitionPage(
            child: ReaderShellPage(
                mangaId: mangaId,
                currentIndex: currentIndex,
                chapters: chapters,
                mangaTitle: mangaTitle,
                coverImageUrl: coverImageUrl,
                chapterNumbers: chapterNumbers,
            ), 
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
               return FadeTransition(opacity: animation, child: child);
            }
           );
        },
      ),
    ],

    redirect: (context, state) {
      final authBloc = GetIt.instance<AuthStatusBloc>();
      final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
      final path = state.uri.path;
      
      final isLoggingIn = path == '/login';
      final isRegistering = path == '/register';

      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home';
      }

      if (!isAuthenticated && path.startsWith('/library')) {
        return '/login';
      }
      
      return null;
    },
  );
}