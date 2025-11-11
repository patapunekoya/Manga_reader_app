import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../page/main_shell.dart';
import '../page/manga_detail_shell_page.dart';
import '../page/reader_shell_page.dart';

/// ===========================================================
/// File: routes/app_router.dart
/// Mục đích:
///   - Khai báo và cấu hình GoRouter cho toàn ứng dụng.
///   - Định nghĩa các tuyến đường (route) cấp cao:
///       • /home, /search, /library: điều hướng vào MainShell theo tab index,
///         không dùng transition vì hiệu ứng chuyển tab do chính MainShell quản lý (PageView).
///       • /manga/:mangaId: màn chi tiết manga, đẩy chồng lên shell với slide-in.
///       • /reader/:chapterId: màn đọc truyện full-screen, slide-in.
/// Điểm vào/ra:
///   - Input: không nhận DI trực tiếp; được tạo ở bootstrap và truyền vào MaterialApp.router.
///   - Output: [GoRouter] cấu hình hoàn chỉnh qua getter [config].
/// Phụ thuộc:
///   - go_router: cung cấp declarative routing API.
///   - MainShell: chứa PageView + BottomNav cho 3 tab chính.
///   - MangaDetailShellPage: hiển thị chi tiết manga, danh sách chương.
///   - ReaderShellPage: viewer ảnh theo chương, hỗ trợ next/prev, resume.
/// Lưu ý & Quy ước:
///   - Các route tab sử dụng NoTransitionPage để không “đè” animation nội bộ của MainShell.
///   - _slidePage: helper tạo slide transition thống nhất cho các màn đẩy lên.
///   - Đọc query/extra an toàn: luôn kiểm tra null/type trước khi cast, có fallback để tránh crash.
///   - URL params:
///       • /manga/:mangaId?from=home|search|library
///       • /reader/:chapterId?mangaId=...&page=...&mangaTitle=...&coverImageUrl=...
///     + state.extra có thể chứa:
///         { chapters: List<String>, chapterNumbers: List, currentIndex: int }
/// ===========================================================
class AppRouter {
  AppRouter();

  // -----------------------------------------------------------
  // Helper: tạo CustomTransitionPage với hiệu ứng slide-in.
  // - [begin]: vector Offset điểm bắt đầu của slide. Mặc định trượt từ phải sang (1, 0).
  // - Trả về: CustomTransitionPage bọc child với SlideTransition + CurveTween mượt.
  // Lưu ý: Không tham chiếu context ngoài phạm vi transitionsBuilder.
  // -----------------------------------------------------------
  CustomTransitionPage<T> _slidePage<T>({
    required Widget child,
    Offset begin = const Offset(1, 0),
  }) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // -----------------------------------------------------------
  // GoRouter cấu hình chính cho app.
  // - initialLocation: '/home' để luôn vào tab Home khi khởi động.
  // - routes: định nghĩa mapping path -> Page builder.
  //   • Tabs: dùng NoTransitionPage để giữ animation của MainShell.
  //   • MangaDetail / Reader: dùng _slidePage cho cảm giác đẩy chồng.
  // -----------------------------------------------------------
  late final GoRouter config = GoRouter(
    initialLocation: '/home',
    routes: [
      // ================== TABS (trong MainShell + PageView) ==================
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

      // ================== MANGA DETAIL ==================
      // Ý tưởng:
      //   - Đọc :mangaId từ pathParameters.
      //   - Đọc query ?from=home|search|library để khi back() trả về đúng tab nguồn.
      //   - Dùng slide-in để “đẩy” trang chi tiết chồng lên shell hiện tại.
      GoRoute(
        path: '/manga/:mangaId',
        pageBuilder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          // Nguồn điều hướng: mặc định 'home' nếu không truyền.
          final origin =
              (state.uri.queryParameters['from'] ?? 'home').toLowerCase();

          return _slidePage(
            child: MangaDetailShellPage(
              mangaId: mangaId,
              origin: origin,
            ),
          );
        },
      ),

      // ================== READER ==================
      // Ý tưởng:
      //   - Đọc :chapterId từ path; query chứa mangaId, page (int), title, cover.
      //   - state.extra có thể cung cấp chapters (list chapterId), chapterNumbers (số chương),
      //     và currentIndex (vị trí chapter hiện tại trong list).
      //   - Có fallback an toàn:
      //       • Nếu extra null hoặc thiếu, tự tạo danh sách 1 phần tử để tránh crash.
      //       • Nếu currentIndex không tìm thấy hoặc âm, đưa về 0.
      GoRoute(
        path: '/reader/:chapterId',
        pageBuilder: (context, state) {
          // Thông tin từ query
          final mangaId = state.uri.queryParameters['mangaId'] ?? '';
          final pageIndexStr = state.uri.queryParameters['page'] ?? '0';
          final initialPageIndex = int.tryParse(pageIndexStr) ?? 0;

          // Param đường dẫn
          final currentChapterId = state.pathParameters['chapterId'] ?? '';

          // Đọc extra an toàn (Map<String, dynamic> hoặc null)
          final extra =
              state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;

          // Danh sách chapterId: nếu không có, fallback [currentChapterId]
          final List<String> chapters = (extra?['chapters'] is List)
              ? List<String>.from(extra!['chapters'] as List)
              : <String>[currentChapterId];

          // Danh sách số chương tương ứng (nếu có). Ép tất cả về String để hiển thị ổn định.
          final List<String>? chapterNumbers = (extra?['chapterNumbers'] is List)
              ? (extra!['chapterNumbers'] as List)
                  .map((e) => e.toString())
                  .toList()
              : null;

          // Metadata hiển thị nhẹ: tiêu đề manga, ảnh bìa
          final String mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
          final String? coverImageUrl = state.uri.queryParameters['coverImageUrl'];

          // Vị trí chương hiện tại trong danh sách
          int currentIndex = (extra?['currentIndex'] is int)
              ? extra!['currentIndex'] as int
              : chapters.indexOf(currentChapterId);
          if (currentIndex < 0) currentIndex = 0;

          return _slidePage(
            child: ReaderShellPage(
              mangaId: mangaId,
              chapters: chapters,
              currentIndex: currentIndex,
              initialPageIndex: initialPageIndex,
              mangaTitle: mangaTitle,
              coverImageUrl: coverImageUrl,
              chapterNumbers: chapterNumbers,
            ),
          );
        },
      ),
    ],
  );
}
