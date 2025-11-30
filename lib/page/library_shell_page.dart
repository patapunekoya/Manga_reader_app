import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// THÊM: Import Auth Module
import 'package:auth/auth.dart';

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
/// CẬP NHẬT: Thêm logic kiểm tra trạng thái Authentication
/// ======================================================================
class LibraryShellPage extends StatefulWidget {
  const LibraryShellPage({super.key});

  @override
  State<LibraryShellPage> createState() => _LibraryShellPageState();
}

class _LibraryShellPageState extends State<LibraryShellPage> {
  // BLoC cho dữ liệu cá nhân (chỉ nên load khi đã Auth)
  late final FavoritesBloc _favoritesBloc;
  late final HistoryBloc _historyBloc;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.instance;
    // Khởi tạo BLoC, nhưng chỉ add sự kiện Load khi đã Auth
    _favoritesBloc = sl<FavoritesBloc>();
    _historyBloc = sl<HistoryBloc>();
    
    // NOTE: Chúng ta không add LoadRequested ở đây. Thay vào đó, chúng ta
    // sẽ gọi chúng trong build() nếu user đã đăng nhập.
  }

  // Tải lại dữ liệu (chỉ được gọi khi đã xác thực)
  void _loadLibraryData() {
    _favoritesBloc.add(const FavoritesLoadRequested());
    _historyBloc.add(const HistoryLoadRequested());
  }

  @override
  void dispose() {
    _favoritesBloc.close();
    _historyBloc.close();
    super.dispose();
  }

  /// Dùng async/await để đợi người dùng quay lại rồi reload History
  Future<void> _resumeReadingFromHistory({
    required String mangaId,
    required String chapterId,
  }) async {
    await context.push(
      "/manga/$mangaId?from=library&resume_chapter=$chapterId"
    );
    
    if (mounted) {
      _historyBloc.add(const HistoryLoadRequested());
      _favoritesBloc.add(const FavoritesLoadRequested()); 
    }
  }

  /// Dùng async/await để đợi người dùng quay lại rồi reload Favorites/History
  Future<void> _openMangaDetail(String mangaId) async {
    await context.push("/manga/$mangaId?from=library");
    
    if (mounted) {
      _favoritesBloc.add(const FavoritesLoadRequested());
      _historyBloc.add(const HistoryLoadRequested());
    }
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
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gỡ khỏi yêu thích")),
      );
    }
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa toàn bộ lịch sử đọc")),
        );
      }
    }
  }

  // NEW: Widget hiển thị khi chưa đăng nhập
  Widget _buildUnauthorizedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Bạn phải đăng nhập để mở khóa thư viện",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Chuyển hướng tới trang Đăng nhập
                context.go('/login');
              },
              icon: const Icon(Icons.login),
              label: const Text("Đăng nhập"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF), // Màu accent
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LẮNG NGHE TRẠNG THÁI XÁC THỰC
    final authStatus = context.watch<AuthStatusBloc>().state.status;
    final isAuthenticated = authStatus == AuthStatus.authenticated;

    // Nếu chưa đăng nhập, hiển thị giao diện khóa
    if (!isAuthenticated) {
      return _buildUnauthorizedView(context);
    }
    
    // Khi đã đăng nhập, tự động kích hoạt tải dữ liệu lần đầu (nếu cần)
    // NOTE: Sử dụng BlocListener hoặc didChangeDependencies để tối ưu hơn,
    // nhưng đây là cách đơn giản nhất để đảm bảo dữ liệu được load sau khi login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ add event nếu BLoC đang ở trạng thái Initial
      if (_historyBloc.state.status == HistoryStatus.initial) {
        _loadLibraryData(); 
      }
    });


    // --- CODE HIỂN THỊ THƯ VIỆN BÌNH THƯỜNG ---
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            _favoritesBloc.add(const FavoritesLoadRequested());
            _historyBloc.add(const HistoryLoadRequested());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

              // ====== GRID YÊU THÍCH ======
              SliverToBoxAdapter(
                child: BlocProvider.value(
                  value: _favoritesBloc,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FavoriteGrid(
                      onTapManga: _openMangaDetail, 
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

              // ====== LIST LỊCH SỬ ======
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
                        _resumeReadingFromHistory(
                          mangaId: mangaId,
                          chapterId: chapterId,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}