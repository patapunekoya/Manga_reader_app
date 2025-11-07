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
  late final ReaderBloc _bloc;
  late int _currentIndex;

  String get _currentChapterId => widget.chapters[_currentIndex];
  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.chapters.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _bloc = GetIt.instance<ReaderBloc>()
      ..add(ReaderLoadChapter(_currentChapterId));

    // Lưu “chương đang đọc” NGAY khi vào chapter
    _saveChapterProgress();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

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

  String _currentChapterNumberForSave() {
    if (widget.chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (widget.chapterNumbers!.length)) {
      final num = widget.chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return num;
    }
    return _currentChapterId;
  }

  String _buildChapterLabel() {
    if (widget.chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (widget.chapterNumbers!.length)) {
      final num = widget.chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return "Ch. $num";
    }
    return "Chapter ${_currentChapterId}";
  }

  void _handleBackToManga() => context.go("/manga/${widget.mangaId}");

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
