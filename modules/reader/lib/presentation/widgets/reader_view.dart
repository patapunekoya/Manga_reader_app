// lib/presentation/widgets/reader_view.dart
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
  final _scrollController = ScrollController();

  // Để tính current page hiển thị, ta track vị trí scroll
  void _handleScroll() {
    final bloc = context.read<ReaderBloc>();
    final st = bloc.state;
    if (st.pages.isEmpty) return;

    // logic đơn giản: tính index gần đầu màn hình
    final pos = _scrollController.position.pixels;
    // height 800 1 trang? Không chính xác.
    // Cách xịn là GlobalKey từng item để lấy offset thực tế,
    // nhưng đó quá nặng cho MVP. Ta tạm dùng guess dựa itemExtent
    // => thay vì Grid, ta render List với Intrinsic height,
    // khó fix-height. Thôi MVP: bỏ tạm, gọi bloc khi user stop scroll
    // -> Đỡ spam.
  }

  Timer? _scrollDebounce;
  void _onScrollDebounced() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 150), () {
      final bloc = context.read<ReaderBloc>();
      final st = bloc.state;
      if (st.pages.isEmpty) return;

      // Thật sự accurate cần đo từng RenderBox.
      // MVP giải pháp tương đối: lấy index gần cuối đã render trên màn.
      // Ta sẽ tính bằng viewportFraction trung bình = 800 px / page
      // Nói thẳng: manga page size khác nhau => ước lượng hơi ngu.
      // Nhưng thôi, miễn chúng ta còn trong phạm vi lab, deal.

      final approxPageHeight = 800.0; // ước lượng
      final scrollPos = _scrollController.position.pixels;
      final idx = (scrollPos / approxPageHeight).floor();
      final safeIdx =
          idx.clamp(0, (st.pages.length - 1)).toInt();

      bloc.add(ReaderSetCurrentPage(PageIndex(safeIdx)));
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
        if (state.status == ReaderStatus.loading ||
            state.status == ReaderStatus.initial) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (state.status == ReaderStatus.failure) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Text(
                "Không tải được chapter.\n${state.errorMessage ?? ""}",
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pages = state.pages;
        final totalPages = pages.length;

        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Scroll pages
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
