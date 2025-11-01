// lib/page/reader_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// bloc đọc truyện
import 'package:reader/presentation/bloc/reader_bloc.dart';
// để dùng ReaderSetCurrentPage(PageIndex(...))
import 'package:reader/domain/value_objects/page_index.dart';

// UI hiển thị trang đọc + toolbar
import 'package:reader/presentation/widgets/reader_view.dart';

/// ReaderShellPage v2
///
/// Nhận:
/// - mangaId: dùng để quay lại MangaDetail
/// - chapters: toàn bộ danh sách chapterId theo thứ tự đọc (List<String>)
/// - currentIndex: index hiện tại trong `chapters`
/// - initialPageIndex: trang resume (ví dụ 12)
///
/// => Nhờ vậy ta biết prev/next chapter thật sự.
class ReaderShellPage extends StatefulWidget {
  final String mangaId;
  final int currentIndex;
  final List<String> chapters;
  final int initialPageIndex;

  const ReaderShellPage({
    super.key,
    required this.mangaId,
    required this.currentIndex,
    required this.chapters,
    required this.initialPageIndex,
  });

  @override
  State<ReaderShellPage> createState() => _ReaderShellPageState();
}

class _ReaderShellPageState extends State<ReaderShellPage> {
  late final ReaderBloc _bloc;

  // giữ index chương hiện tại (mutable để next/prev đổi được)
  late int _currentIndex;

  String get _currentChapterId => widget.chapters[_currentIndex];

  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.chapters.length - 1;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.currentIndex;

    _bloc = GetIt.instance<ReaderBloc>();

    // load chương ban đầu
    _bloc.add(ReaderLoadChapter(_currentChapterId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // ====== callback cho toolbar ======

  void _handleBackToManga() {
    // quay lại detail manga
    context.go("/manga/${widget.mangaId}");
  }

  void _handlePrevChapter() {
    if (!_hasPrev) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang ở chương đầu rồi")),
      );
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });

    _bloc.add(ReaderLoadChapter(_currentChapterId));
  }

  void _handleNextChapter() {
    if (!_hasNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hết chương rồi")),
      );
      return;
    }

    setState(() {
      _currentIndex += 1;
    });

    _bloc.add(ReaderLoadChapter(_currentChapterId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _bloc,
          child: BlocListener<ReaderBloc, ReaderState>(
            listenWhen: (prev, curr) {
              // Khi vừa load xong 1 chương mới thành công
              final justLoaded = prev.status != ReaderStatus.success &&
                  curr.status == ReaderStatus.success;

              // Và chương trong state đúng là chương hiện tại mình muốn
              final sameChapter = curr.chapterId == _currentChapterId;

              return justLoaded && sameChapter;
            },
            listener: (context, state) {
              // resume tới trang đã đọc dở chỉ khi mở lần đầu
              if (widget.initialPageIndex > 0) {
                context.read<ReaderBloc>().add(
                      ReaderSetCurrentPage(
                        PageIndex(widget.initialPageIndex),
                      ),
                    );
              }
            },
            child: BlocBuilder<ReaderBloc, ReaderState>(
              builder: (context, state) {
                final toolbarLabel = "Chapter $_currentChapterId";

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
      ),
    );
  }
}
