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

/// ======================================================================
/// File: page/library_shell_page.dart
/// Mục đích:
///   - “Shell page” cho tab Thư viện: quản lý 2 khối dữ liệu cục bộ (Hive):
///       • Yêu thích (Favorites)   → FavoritesBloc
///       • Lịch sử đọc (History)   → HistoryBloc
///   - Render giao diện 2 section bằng CustomScrollView + SliverToBoxAdapter:
///       • Grid Yêu thích (không tự cuộn)
///       • Danh sách Lịch sử (không tự cuộn)
///   - Điều hướng:
///       • Tới Manga Detail khi chạm vào item yêu thích
///       • Tới Reader khi resume từ lịch sử
///
/// Dòng chảy dữ liệu:
///   UI -> (FavoritesLoadRequested | HistoryLoadRequested)
///     -> {FavoritesBloc | HistoryBloc} -> đọc Hive qua repository
///     -> phát state cho FavoriteGrid / HistoryList hiển thị.
///
/// Lưu ý:
///   - Lấy bloc qua GetIt trong initState, nhớ close() trong dispose.
///   - Xóa yêu thích có confirm; gọi ToggleFavorite use case rồi reload danh sách.
///   - “Xóa tất cả” lịch sử có confirm; bắn HistoryClearAllRequested.
///   - Các widget con (FavoriteGrid/HistoryList) không tự cuộn để tránh xung đột
///     với CustomScrollView bên ngoài.
/// ======================================================================
class LibraryShellPage extends StatefulWidget {
  const LibraryShellPage({super.key});

  @override
  State<LibraryShellPage> createState() => _LibraryShellPageState();
}

class _LibraryShellPageState extends State<LibraryShellPage> {
  // Hai bloc tách biệt cho Favorites và History (đồng bộ hóa độc lập)
  late final FavoritesBloc _favoritesBloc;
  late final HistoryBloc _historyBloc;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.instance;

    // Khởi động: nạp dữ liệu cho cả hai khối
    _favoritesBloc = sl<FavoritesBloc>()..add(const FavoritesLoadRequested());
    _historyBloc = sl<HistoryBloc>()..add(const HistoryLoadRequested());
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên stream/subscription
    _favoritesBloc.close();
    _historyBloc.close();
    super.dispose();
  }

  /// Điều hướng mở Reader với ngữ cảnh tối thiểu:
  /// - URL schema: /reader/:chapterId?mangaId=...&page=...
  void _openReader({
    required String mangaId,
    required String chapterId,
    required int pageIndex,
  }) {
    context.push("/reader/$chapterId?mangaId=$mangaId&page=$pageIndex");
  }

  /// Điều hướng mở trang chi tiết Manga:
  /// - URL schema: /manga/:mangaId
  void _openMangaDetail(String mangaId) {
    context.push("/manga/$mangaId");
  }

  /// Xác nhận và gỡ 1 mục khỏi danh sách yêu thích.
  /// Quy trình:
  ///   1) Hỏi xác nhận bằng AlertDialog.
  ///   2) Nếu đồng ý: gọi UseCase ToggleFavorite để đảo trạng thái.
  ///   3) Reload FavoritesBloc và báo SnackBar.
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

  /// Xác nhận và xóa toàn bộ lịch sử đọc.
  /// - Bắn sự kiện HistoryClearAllRequested vào HistoryBloc nếu người dùng đồng ý.
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
      // Dùng màu nền thống nhất từ bảng màu dùng chung
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // tránh đẩy nội dung lên khi có gesture/bottom bar
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
                value: _favoritesBloc, // cung cấp bloc hiện hữu cho subtree
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FavoriteGrid(
                    onTapManga: _openMangaDetail,      // chạm → mở chi tiết
                    onLongPressManga: _confirmAndRemoveFavorite, // nhấn giữ → gỡ yêu thích
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // chừa đáy cho bottom nav
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
