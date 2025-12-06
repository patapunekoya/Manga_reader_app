// lib/page/search_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core.dart';

import 'package:catalog/presentation/bloc/search_bloc.dart';
import 'package:catalog/presentation/widgets/search_view.dart';

/// ======================================================================
/// File: page/search_shell_page.dart
/// Mục đích:
///   - “Shell” mỏng cho tính năng Tìm kiếm.
///   - Lấy SearchBloc từ DI và cung cấp cho SearchView.
///   - Điều hướng sang Manga Detail khi người dùng chọn một kết quả.
/// Dòng chảy:
///   - SearchView quản lý input + debounce và tự bắn event SearchStarted/SearchTextChanged.
///   - SearchBloc xử lý, phát state → SearchView render kết quả.
/// Lưu ý:
///   - Không dispatch event trong initState; để SearchView chủ động theo tương tác người dùng.
///   - Đóng _searchBloc trong dispose để giải phóng tài nguyên.
/// ======================================================================
class SearchShellPage extends StatefulWidget {
  const SearchShellPage({super.key});

  @override
  State<SearchShellPage> createState() => _SearchShellPageState();
}

class _SearchShellPageState extends State<SearchShellPage> {
  // Bloc tìm kiếm được inject qua GetIt (đăng ký ở bootstrap/locator)
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = GetIt.instance<SearchBloc>();
    // Không dispatch ở đây; SearchView sẽ bắn SearchStarted khi user gõ.
  }

  @override
  void dispose() {
    _searchBloc.close();
    super.dispose();
  }

  /// Điều hướng tới trang chi tiết manga với schema /manga/:mangaId
  void _openMangaDetail(String mangaId) {
    context.push("/manga/$mangaId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền tối đồng bộ palette chung của app
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // tránh bị co nội dung nếu có system gesture/bottom bar
        child: BlocProvider.value(
          // Cấp phát bloc hiện có cho subtree của SearchView
          value: _searchBloc,
          child: Padding(
            // Chừa đáy 80 để không đụng BottomNav/MainShell
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: SearchView(
              // Callback khi chọn một manga trong kết quả
              onTapManga: _openMangaDetail,
            ),
          ),
        ),
      ),
    );
  }
}
