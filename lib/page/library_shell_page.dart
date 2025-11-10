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

// Usecase để toggle favorite
import 'package:library_manga/application/usecases/toggle_favorite.dart';
import 'package:library_manga/domain/entities/favorite_item.dart';

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

  Future<void> _confirmAndRemoveFavorite(FavoriteItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Gỡ khỏi yêu thích?"),
        content: Text('Xóa “${item.title}” khỏi danh sách yêu thích?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa")),
        ],
      ),
    );
    if (ok != true) return;

    final sl = GetIt.instance;
    final toggle = sl<ToggleFavorite>();
    await toggle(
      mangaId: item.id.value,
      title: item.title,
      coverImageUrl: item.coverImageUrl,
    );

    _favoritesBloc.add(const FavoritesLoadRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã gỡ khỏi yêu thích")),
    );
  }

  Future<void> _confirmAndClearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa toàn bộ lịch sử đọc?"),
        content: const Text("Hành động này sẽ xóa toàn bộ tiến trình đọc đã lưu."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa hết")),
        ],
      ),
    );
    if (ok == true) {
      _historyBloc.add(const HistoryClearAllRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa toàn bộ lịch sử đọc")),
      );
    }
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
                      onPressed: () => _favoritesBloc.add(const FavoritesLoadRequested()),
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
                    // NHẤN-GIỮ để gỡ
                    onLongPressManga: _confirmAndRemoveFavorite,
                  ),
                ),
              ),
            ),

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
                    TextButton.icon(
                      onPressed: _confirmAndClearHistory,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text("Xóa tất cả"),
                    ),
                    IconButton(
                      tooltip: 'Làm mới',
                      onPressed: () => _historyBloc.add(const HistoryLoadRequested()),
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
