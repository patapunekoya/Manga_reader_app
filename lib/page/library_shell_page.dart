// lib/page/library_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// Bloc từ module library_manga
import 'package:library_manga/presentation/bloc/favorites_bloc.dart';
import 'package:library_manga/presentation/bloc/history_bloc.dart';

// Widgets
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

    _favoritesBloc = sl<FavoritesBloc>()..add(const FavoritesLoadRequested());
    _historyBloc = sl<HistoryBloc>()..add(const HistoryLoadRequested());
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
    context.push("/reader/$chapterId?mangaId=$mangaId&page=$pageIndex");
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
        child: CustomScrollView(
          slivers: [
            // ====== HEADER: YÊU THÍCH ======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Yêu thích",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Làm mới',
                      onPressed: () =>
                          _favoritesBloc.add(const FavoritesLoadRequested()),
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // ====== GRID YÊU THÍCH (không tự cuộn) ======
            SliverToBoxAdapter(
              child: BlocProvider.value(
                value: _favoritesBloc,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FavoriteGrid(
                    onTapManga: _openMangaDetail,
                    // nếu FavoriteGrid của bạn đã set shrinkWrap + NeverScrollable,
                    // để trống params là đủ. Nếu mình có expose thêm options, có thể set ở đây.
                  ),
                ),
              ),
            ),

            // spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ====== HEADER: LỊCH SỬ ======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Lịch sử đọc",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Làm mới',
                      onPressed: () =>
                          _historyBloc.add(const HistoryLoadRequested()),
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // ====== LIST LỊCH SỬ (không tự cuộn) ======
            SliverToBoxAdapter(
              child: BlocProvider.value(
                value: _historyBloc,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
