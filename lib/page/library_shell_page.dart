// lib/page/library_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// Bloc từ module library_manga
import 'package:library_manga/presentation/bloc/favorites_bloc.dart';

import 'package:library_manga/presentation/bloc/history_bloc.dart';


// Widgets từ module library_manga
import 'package:library_manga/presentation/widgets/favorite_grid.dart';
import 'package:library_manga/presentation/widgets/history_list.dart';

class LibraryShellPage extends StatefulWidget {
  const LibraryShellPage({super.key});

  @override
  State<LibraryShellPage> createState() => _LibraryShellPageState();
}

class _LibraryShellPageState extends State<LibraryShellPage> {
  late final FavoritesBloc _favoritesBloc;
  late final HistoryBloc _historyBloc;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.instance;

    _favoritesBloc = sl<FavoritesBloc>()
      ..add(const FavoritesLoadRequested());

    _historyBloc = sl<HistoryBloc>()
      ..add(const HistoryLoadRequested());
  }

  @override
  void dispose() {
    _favoritesBloc.close();
    _historyBloc.close();
    super.dispose();
  }

  void _openReader({
    required String mangaId,
    required String chapterId,
    required int pageIndex,
  }) {
    context.push(
      "/reader/$chapterId?mangaId=$mangaId&page=$pageIndex",
    );
  }

  void _openMangaDetail(String mangaId) {
    context.push("/manga/$mangaId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Yêu thích",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              BlocProvider.value(
                value: _favoritesBloc,
                child: FavoriteGrid(
                  onTapManga: _openMangaDetail,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Lịch sử đọc",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              BlocProvider.value(
                value: _historyBloc,
                child: HistoryList(
                  onResumeReading: ({
                    required String mangaId,
                    required String chapterId,
                    required int pageIndex,
                  }) {
                    _openReader(
                      mangaId: mangaId,
                      chapterId: chapterId,
                      pageIndex: pageIndex,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
