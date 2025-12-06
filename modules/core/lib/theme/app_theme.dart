import 'package:flutter/material.dart';
// SỬA DÒNG NÀY: thay 'colors.dart' bằng 'app_colors.dart'
import 'app_colors.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
  );
}

ThemeData buildAppTheme() {
  // dùng dark làm default
  return buildDarkTheme();
}
