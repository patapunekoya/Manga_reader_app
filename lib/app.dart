// lib/app.dart
import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class MangaReaderApp extends StatelessWidget {
  final AppRouter router;

  const MangaReaderApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Manga Reader',
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router.config,
    );
  }
}
