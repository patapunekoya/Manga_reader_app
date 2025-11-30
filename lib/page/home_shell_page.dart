import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

import 'package:home/presentation/bloc/home_bloc.dart';
import 'package:home/presentation/bloc/home_event.dart';
import 'package:home/presentation/bloc/home_state.dart';

// widgets mới
import 'package:home/presentation/widgets/recommended_carousel.dart';
import 'package:home/presentation/widgets/latest_updates_list.dart';
import 'package:home/presentation/widgets/continue_reading_strip.dart';

/// ===============================================================
/// File: page/home_shell_page.dart
/// Chức năng tổng quát:
///   - Là "shell" mỏng cho màn Home. Không chứa logic domain.
///   - Khởi tạo và gắn HomeBloc (qua GetIt) để load HomeVM (recommended,
///     latest updates, continue reading) rồi render UI.
///   - Điều hướng đến MangaDetail và Reader theo tương tác người dùng.
///
/// Dòng chảy dữ liệu:
///   UI -> gửi HomeLoadRequested -> HomeBloc -> UseCase build_home_vm
///   -> phát HomeState { recommended, latestUpdates, continueReading }
///
/// Lưu ý:
///   - DI: lấy HomeBloc từ GetIt trong initState và đóng trong dispose.
///   - Navigation: dùng GoRouter context.push(...) theo schema đã định.
///   - UI chia 3 section chính: Recommended, Latest Updates, Continue Reading.
/// ===============================================================
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  // Bloc được inject từ GetIt (đã register ở bootstrap)
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    // Lấy instance và trigger tải dữ liệu ngay khi mount.
    _homeBloc = GetIt.instance<HomeBloc>()
      ..add(const HomeLoadRequested());
  }

  @override
  void dispose() {
    // Đóng bloc để giải phóng stream/subscription.
    _homeBloc.close();
    super.dispose();
  }

  /// Điều hướng sang Reader từ strip "Đang đọc dở".
  /// - Bảo toàn context đọc: truyền mangaId, chapterId, pageIndex qua query.
  /// - Schema URL: /reader/:chapterId?mangaId=...&page=...
  void _openReaderFromContinue({
    required String mangaId,
    required String chapterId,
    required int pageIndex,
  }) {
    context.push(
      "/reader/$chapterId?mangaId=$mangaId&page=$pageIndex",
    );
  }

  /// Điều hướng sang Manga Detail.
  /// - Schema URL: /manga/:mangaId
  void _openMangaDetail(String mangaId) {
    context.push("/manga/$mangaId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền dùng bảng màu chung (theme/colors.dart)
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // để nội dung có thể tràn xuống sát bottom nếu cần
        child: BlocProvider.value(
          // Cấp phát bloc đã tạo ở initState cho subtree
          value: _homeBloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              // Trạng thái tải
              final isLoading = state.status == HomeStatus.loading ||
                  state.status == HomeStatus.initial;
              final isError = state.status == HomeStatus.failure;

              if (isLoading) {
                // Skeleton đơn giản. Có thể thay bằng shimmer về sau.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            // --- UI FALLBACK MỚI ---
              if (isError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.white38),
                      const SizedBox(height: 16),
                      const Text(
                        "Không tải được dữ liệu.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Thử lại"),
                        onPressed: () {
                          // Gọi sự kiện Refresh để load lại toàn bộ Home
                          context.read<HomeBloc>().add(const HomeRefreshRequested());
                        },
                      ),
                      // Hiển thị lỗi kỹ thuật nhỏ bên dưới để debug (tuỳ chọn)
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(fontSize: 10, color: Colors.white24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                );
              }

              // Trạng thái success: render cả 3 section
              return SingleChildScrollView(
                // Padding dưới 80 để chừa chỗ cho bottom nav/gesture
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Recommended Carousel =====
                    const Text(
                      "Recommended for you",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Gợi ý theo home VM; onTap -> mở chi tiết
                    RecommendedCarousel(
                      items: state.recommended,
                      onTapManga: _openMangaDetail,
                    ),

                    const SizedBox(height: 24),

                    // ===== Latest Updates (list dọc) =====
                    const Text(
                      "Latest Updates",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Danh sách cập nhật mới nhất; onTap -> mở chi tiết
                    LatestUpdatesList(
                      items: state.latestUpdates,
                      onTapManga: _openMangaDetail,
                    ),

                    const SizedBox(height: 24),

                    // ===== Continue Reading (ngang) =====
                    const Text(
                      "Đang đọc dở",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lịch sử đọc gần nhất; onTap -> nhảy thẳng vào Reader
                    ContinueReadingStrip(
                      items: state.continueReading,
                      onTapContinue: ({
                        required String mangaId,
                        required String chapterId,
                        required int pageIndex,
                      }) {
                        _openReaderFromContinue(
                          mangaId: mangaId,
                          chapterId: chapterId,
                          pageIndex: pageIndex,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
