// lib/presentation/widgets/reader_view.dart
//
// ReaderView
// -----------------------------
// Mục đích:
// - Màn đọc truyện toàn màn hình nền tối.
// - Hiển thị danh sách trang (PageImage) theo chiều dọc, lazy-load bằng CachedNetworkImage.
// - Đồng bộ vị trí trang hiện tại về ReaderBloc khi người dùng cuộn.
// - Render thanh công cụ (ReaderToolbar) ở đáy để Back/Prev/Next chapter.
//
// Vị trí trong flow:
// - Được dùng bên trong ReaderShellPage (nơi tạo BlocProvider<ReaderBloc> và bắn ReaderLoadChapter).
// - ReaderBloc lo gọi usecase lấy trang, prefetch, lưu progress theo CHAPTER.
// - ReaderView chỉ là UI + scroll listener, không gọi network trực tiếp.
//
// Props cần truyền từ shell:
// - onBackToManga: callback điều hướng về Manga Detail.
// - onPrevChapter / onNextChapter: callback điều hướng sang chapter trước/sau.
// - chapterLabel: chuỗi hiển thị nhãn chapter hiện tại, ví dụ "Ch.123".
//
// Lưu ý kỹ thuật:
// - Để tránh tốn kém, ta KHÔNG dùng GlobalKey per item để đo chính xác chiều cao từng ảnh.
//   Thay vào đó ước lượng sơ bộ (approxPageHeight = 800) rồi suy ra index hiện tại dựa trên
//   scrollPixels / approxHeight. Cách này nhanh, ít rắc rối, chấp nhận sai số nhỏ.
// - Với ảnh manga dọc, AspectRatio ~0.66–0.7 là hợp lý để layout ổn trên nhiều thiết bị.
// - CachedNetworkImage tự lo placeholder, error và cache. Khi fail, ta gửi ReaderReportImageFailed
//   để repo có thể log/analytics mà không ảnh hưởng UI.
//
// Hiệu năng/UX:
// - Debounce khi lắng nghe scroll (180ms) để không spam event về Bloc.
// - Prefetch logic nằm trong Bloc khi chuyển trang, ở đây chỉ cập nhật current page.
// - Toolbar overlay có padding bottom để tránh che nội dung.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../bloc/reader_bloc.dart';
import '../../domain/entities/page_image.dart';
import '../../domain/value_objects/page_index.dart';
import 'reader_toolbar.dart';

/// ReaderView:
/// - full màn tối
/// - scroll dọc list ảnh
/// - auto lazy load (CachedNetworkImage đã lo phần cache/lazy)
/// - update current page vào bloc khi người dùng scroll
///
/// Dùng trong ReaderShellPage:
/// BlocProvider(
///   create: (_) => sl<ReaderBloc>()..add(ReaderLoadChapter(chapterId)),
///   child: ReaderView(
///     onBackToManga: () { go_router back manga detail },
///     onPrevChapter: () { ... },
///     onNextChapter: () { ... },
///     chapterLabel: "Ch.123",
///   ),
/// )
class ReaderView extends StatefulWidget {
  final VoidCallback onBackToManga;
  final VoidCallback onPrevChapter;
  final VoidCallback onNextChapter;
  final String? chapterLabel;

  const ReaderView({
    super.key,
    required this.onBackToManga,
    required this.onPrevChapter,
    required this.onNextChapter,
    this.chapterLabel,
  });

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  // Controller cho ListView để nghe vị trí cuộn
  final _scrollController = ScrollController();

  // Debounce để hạn chế dispatch ReaderSetCurrentPage quá dày
  Timer? _scrollDebounce;

  // Tính index trang hiện tại từ vị trí scroll (xấp xỉ)
  void _onScrollDebounced() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 180), () {
      final bloc = context.read<ReaderBloc>();
      final st = bloc.state;
      if (st.pages.isEmpty) return;

      // Ước lượng chiều cao 1 trang — giải pháp nhẹ, tránh GlobalKey nặng nề
      const approxPageHeight = 800.0;
      final scrollPos = _scrollController.position.pixels;
      final idx = (scrollPos / approxPageHeight).floor();
      final safeIdx = idx.clamp(0, (st.pages.length - 1)).toInt();

      // chỉ dispatch khi thật sự khác để tránh lưu spam
      if (safeIdx != st.currentPage.value) {
        bloc.add(ReaderSetCurrentPage(PageIndex(safeIdx)));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollDebounced);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Render 1 trang (PageImage)
  // - Dùng CachedNetworkImage để có placeholder + cache
  // - Khi lỗi ảnh: dispatch ReaderReportImageFailed để repo log
  Widget _buildPageItem(PageImage page, int totalPages) {
    final bloc = context.read<ReaderBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AspectRatio(
        aspectRatio: 0.7, // tỉ lệ manga trang dọc gần 2:3 -> 0.66~0.7
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: page.imageUrl,
            fit: BoxFit.contain,
            placeholder: (ctx, _) => Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
            errorWidget: (ctx, _, __) {
              // báo lỗi về bloc (analytics)
              bloc.add(ReaderReportImageFailed(
                pageIndex: page.index,
                imageUrl: page.imageUrl,
              ));
              return Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.white38,
                  size: 48,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        // Trạng thái loading/initial: nền đen + spinner trắng
        if (state.status == ReaderStatus.loading ||
            state.status == ReaderStatus.initial) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

// =======================================================================
        // CẬP NHẬT: Trạng thái failure - Lọc Lỗi Hiển Thị
        // =======================================================================
        if (state.status == ReaderStatus.failure) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // HIỂN THỊ THÔNG BÁO ĐƠN GIẢN VÀ THÂN THIỆN
                    Text(
                      "Mạng không ổn định hoặc không tải được truyện.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vui lòng kiểm tra kết nối và thử lại.",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        // Bắn event RetryLoad vào Bloc
                        context.read<ReaderBloc>().add(const ReaderRetryLoad());
                      },
                      label: const Text("Tải lại"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Trạng thái success: có pages để hiển thị
        final pages = state.pages;
        final totalPages = pages.length;

        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Scroll pages
              // - padding bottom 100 để chừa chỗ cho toolbar không che nội dung
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final p = pages[index];
                  return _buildPageItem(p, totalPages);
                },
              ),

              // bottom toolbar overlay
              // - Gọi ReaderToolbar đã tách riêng widget
              // - Truyền currentPage từ state.currentPage.value
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ReaderToolbar(
                  onBackToManga: widget.onBackToManga,
                  onPrevChapter: widget.onPrevChapter,
                  onNextChapter: widget.onNextChapter,
                  currentPage: state.currentPage.value,
                  totalPages: totalPages,
                  chapterLabel: widget.chapterLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
