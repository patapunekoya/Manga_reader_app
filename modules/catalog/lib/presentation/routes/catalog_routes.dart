import 'package:flutter/material.dart';
import 'package:shared_dependencies/shared_dependencies.dart';
import '../pages/manga_detail_shell_page.dart';
import '../pages/search_shell_page.dart';
import '../../domain/entities/manga.dart'; 
import '../../presentation/widgets/manga_detail_view.dart';

class CatalogRoutes {
  static List<GoRoute> get routes => [
    // Route: Search Page (Tab 2 trong MainShell, nhưng cũng có thể gọi lẻ)
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SearchShellPage(), // Widget này giờ nằm trong module catalog
      ),
    ),

    // Route: Manga Detail (Slide transition)
    GoRoute(
      path: '/manga/:mangaId',
      pageBuilder: (context, state) {
        final mangaId = state.pathParameters['mangaId'] ?? '';
        final origin = (state.uri.queryParameters['from'] ?? 'home').toLowerCase();
        final resumeChapterId = state.uri.queryParameters['resume_chapter'];

        return CustomTransitionPage(
          key: state.pageKey,
          child: MangaDetailShellPage(
            mangaId: mangaId,
            origin: origin,
            resumeChapterId: resumeChapterId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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