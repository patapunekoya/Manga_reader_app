// lib/main.dart
import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'routes/app_router.dart';
import 'app.dart';

void main() async {
  await bootstrap();

  final router = AppRouter();
  runApp(MangaReaderApp(router: router));
}
