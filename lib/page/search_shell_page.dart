// lib/page/search_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

import 'package:catalog/presentation/bloc/search_bloc.dart';
import 'package:catalog/presentation/widgets/search_view.dart';

class SearchShellPage extends StatefulWidget {
  const SearchShellPage({super.key});

  @override
  State<SearchShellPage> createState() => _SearchShellPageState();
}

class _SearchShellPageState extends State<SearchShellPage> {
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = GetIt.instance<SearchBloc>();
    // không dispatch ở đây, SearchView tự bắn SearchStarted khi user gõ
  }

  @override
  void dispose() {
    _searchBloc.close();
    super.dispose();
  }

  void _openMangaDetail(String mangaId) {
    // điều hướng sang trang chi tiết manga
    context.push("/manga/$mangaId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _searchBloc,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: SearchView(
              onTapManga: _openMangaDetail,
            ),
          ),
        ),
      ),
    );
  }
}
