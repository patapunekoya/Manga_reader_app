import 'package:flutter/material.dart';
import 'package:shared_dependencies/shared_dependencies.dart'; // chứa go_router
import '../../presentation/widgets/reader_view.dart'; // Import widget màn hình chính
import '../page/reader_shell_page.dart'; // Import shell page chứa logic (copy file này từ lib/page/ về module/reader/presentation/pages/ nếu chưa có)

// Giả định bạn đã chuyển ReaderShellPage vào: modules/reader/lib/presentation/pages/reader_shell_page.dart
// Nếu chưa, bạn nên move file đó vào module này để module khép kín hoàn toàn.
// Ở đây tôi dùng đường dẫn giả định là bạn đã move file.
import 'package:reader/presentation/page/reader_shell_page.dart';

class ReaderRoutes {
  static const String readerRouteName = 'reader';

  static List<GoRoute> get routes => [
    GoRoute(
      name: readerRouteName,
      path: '/reader/:chapterId',
      pageBuilder: (context, state) {
        // 1. Parse params từ URL
        final currentChapterId = state.pathParameters['chapterId'] ?? '';
        final mangaId = state.uri.queryParameters['mangaId'] ?? '';
        final mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
        final coverImageUrl = state.uri.queryParameters['coverImageUrl'];
        
        // 2. Parse extra data (List chapters context)
        // Logic này chuyển từ app_router.dart cũ về đây
        final extra = state.extra as Map<String, dynamic>?;
        
        final List<String> chapters = (extra?['chapters'] is List)
            ? List<String>.from(extra!['chapters'] as List)
            : <String>[currentChapterId];

        final List<String>? chapterNumbers = (extra?['chapterNumbers'] is List)
            ? (extra!['chapterNumbers'] as List).map((e) => e.toString()).toList()
            : null;

        int currentIndex = (extra?['currentIndex'] is int)
            ? extra!['currentIndex'] as int
            : chapters.indexOf(currentChapterId);
        if (currentIndex < 0) currentIndex = 0;

        // 3. Trả về Page với Slide Transition
        return CustomTransitionPage(
          key: state.pageKey,
          child: ReaderShellPage(
            mangaId: mangaId,
            currentIndex: currentIndex,
            chapters: chapters,
            mangaTitle: mangaTitle,
            coverImageUrl: coverImageUrl,
            chapterNumbers: chapterNumbers,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Hiệu ứng trượt từ phải sang
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      },
    ),
  ];
}