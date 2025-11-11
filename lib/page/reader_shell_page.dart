// lib/page/reader_shell_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// bloc đọc truyện
import 'package:reader/presentation/bloc/reader_bloc.dart';

// UI view
import 'package:reader/presentation/widgets/reader_view.dart';

// Lưu tiến trình theo CHAPTER
import 'package:reader/application/usecases/save_read_progress.dart' as reader_uc;

/// ======================================================================
/// File: page/reader_shell_page.dart
/// Mục đích:
///   - “Shell” mỏng cho màn đọc truyện (Reader).
///   - Quản lý chỉ số chapter hiện tại (currentIndex) và điều hướng Prev/Next.
///   - Lấy ReaderBloc từ DI, load trang ảnh theo chapterId.
///   - Ghi lại tiến trình đọc (per chapter) vào Library ngay khi vào/chuyển chapter.
/// Dòng chảy:
///   - Khi khởi tạo: lấy ReaderBloc từ GetIt → add(ReaderLoadChapter(currentChapterId))
///   - Mỗi lần vào/chuyển chapter: gọi SaveReadProgress(mangaId, chapterId, chapterNumber)
///   - ReaderView nhận callback: back, prev, next, và label chapter hiển thị.
/// Lưu ý:
///   - Không đọc context trong initState cho routing; chỉ dùng cho push/go trong callback.
///   - chapterNumbers là optional, dùng để hiển thị và lưu progress “đẹp” (nếu có).
///   - initialPageIndex giữ để tương thích API cũ, hiện không dùng.
/// ======================================================================
class ReaderShellPage extends StatefulWidget {
  final String mangaId;
  final int currentIndex;
  final List<String> chapters;

  // optional: để hiển thị/ghi progress đẹp
  final String mangaTitle;
  final String? coverImageUrl;
  final List<String>? chapterNumbers;

  // vẫn giữ tham số này cho tương thích, nhưng không dùng nữa
  final int initialPageIndex;

  const ReaderShellPage({
    super.key,
    required this.mangaId,
    required this.currentIndex,
    required this.chapters,
    required this.mangaTitle,
    this.coverImageUrl,
    this.chapterNumbers,
    this.initialPageIndex = 0,
  });

  @override
  State<ReaderShellPage> createState() => _ReaderShellPageState();
}

class _ReaderShellPageState extends State<ReaderShellPage> {
  // Bloc render nội dung chapter (danh sách ảnh, trạng thái tải, …)
  late final ReaderBloc _bloc;

  // Chỉ số chapter hiện tại trong mảng chapters
  late int _currentIndex;

  // Convenience getters
  String get _currentChapterId => widget.chapters[_currentIndex];
  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.chapters.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _bloc = GetIt.instance<ReaderBloc>()
      ..add(ReaderLoadChapter(_currentChapterId));

    // Lưu “chương đang đọc” NGAY khi vào chapter đầu tiên
    _saveChapterProgress();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// Ghi tiến trình đọc theo CHAPTER vào Library.
  /// - Sử dụng use case SaveReadProgress (được đăng ký qua DI).
  /// - Im lặng nếu có lỗi (không làm gián đoạn trải nghiệm đọc).
  void _saveChapterProgress() async {
    try {
      final saver = GetIt.instance<reader_uc.SaveReadProgress>();
      await saver(
        mangaId: widget.mangaId,
        mangaTitle: widget.mangaTitle,
        coverImageUrl: widget.coverImageUrl,
        chapterId: _currentChapterId,
        chapterNumber: _currentChapterNumberForSave(),
      );
    } catch (_) {
      // im lặng
    }
  }

  /// Lấy “chapterNumber” để lưu/hiển thị:
  /// - Ưu tiên lấy từ widget.chapterNumbers nếu có và hợp lệ
  /// - Nếu không có → fallback về chapterId (để không trống)
  String _currentChapterNumberForSave() {
    if (widget.chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (widget.chapterNumbers!.length)) {
      final num = widget.chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return num;
    }
    return _currentChapterId;
  }

  /// Chuẩn hóa nhãn hiển thị trên toolbar:
  /// - Nếu có chapterNumbers → “Ch. <num>”
  /// - Ngược lại → “Chapter <chapterId>”
  String _buildChapterLabel() {
    if (widget.chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (widget.chapterNumbers!.length)) {
      final num = widget.chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return "Ch. $num";
    }
    return "Chapter ${_currentChapterId}";
  }

  /// Quay về trang chi tiết Manga đang đọc
  void _handleBackToManga() => context.go("/manga/${widget.mangaId}");

  /// Chuyển về chương trước:
  /// - Nếu không có prev → báo SnackBar thân thiện
  /// - Nếu có: giảm index, load chapter mới, lưu progress
  void _handlePrevChapter() {
    if (!_hasPrev) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang ở chương đầu rồi")),
      );
      return;
    }
    setState(() => _currentIndex -= 1);
    _bloc.add(ReaderLoadChapter(_currentChapterId));
    _saveChapterProgress();
  }

  /// Chuyển sang chương kế:
  /// - Nếu hết chương → báo SnackBar thân thiện
  /// - Nếu còn: tăng index, load chapter mới, lưu progress
  void _handleNextChapter() {
    if (!_hasNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hết chương rồi")),
      );
      return;
    }
    setState(() => _currentIndex += 1);
    _bloc.add(ReaderLoadChapter(_currentChapterId));
    _saveChapterProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<ReaderBloc, ReaderState>(
            builder: (context, state) {
              final toolbarLabel = _buildChapterLabel();
              return ReaderView(
                onBackToManga: _handleBackToManga,
                onPrevChapter: _handlePrevChapter,
                onNextChapter: _handleNextChapter,
                chapterLabel: toolbarLabel,
              );
            },
          ),
        ),
      ),
    );
  }
}
