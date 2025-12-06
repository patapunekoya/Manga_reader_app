// lib/page/reader_shell_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core.dart';

// bloc đọc truyện
import 'package:reader/presentation/bloc/reader_bloc.dart';
// UI view
import 'package:reader/presentation/widgets/reader_view.dart';
// Lưu tiến trình
import 'package:reader/application/usecases/save_read_progress.dart' as reader_uc;

// --- CÁC IMPORT ĐỂ FETCH CONTEXT VÀ RECOVER DATA ---
import 'package:catalog/application/usecases/list_chapters.dart';
import 'package:catalog/application/usecases/get_manga_detail.dart'; // NEW
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/entities/chapter.dart';
import 'package:library_manga/application/usecases/get_continue_reading.dart'; // NEW: Để lấy lại data từ history cũ


/// ======================================================================
/// File: page/reader_shell_page.dart
/// CẬP NHẬT: 
/// 1. Auto-fetch chapter list nếu thiếu (Fix lỗi không next/prev)
/// 2. Metadata Recovery: Nếu thiếu bìa/tên, tìm lại trong History hoặc API 
///    trước khi lưu, tránh ghi đè dữ liệu lỗi (Fix lỗi mất bìa).
/// ======================================================================
class ReaderShellPage extends StatefulWidget {
  final String mangaId;
  final int currentIndex;
  final List<String> chapters; 

  final String mangaTitle;
  final String? coverImageUrl;
  final List<String>? chapterNumbers; 

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

  late List<String> _chapterIds;
  late List<String>? _chapterNumbers;
  late int _currentIndex;
  
  bool _isFetchingContext = false;
  
  // NEW: Trạng thái đang khôi phục metadata
  bool _isRecoveringMetadata = false;
  late String _currentMangaTitle;
  late String? _currentCoverUrl;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<ReaderBloc>();
    
    _chapterIds = widget.chapters;
    _chapterNumbers = widget.chapterNumbers;
    _currentIndex = widget.currentIndex;
    
    _currentMangaTitle = widget.mangaTitle;
    _currentCoverUrl = widget.coverImageUrl;

    // KIỂM TRA METADATA: Nếu thiếu tên hoặc bìa, thực hiện khôi phục trước khi load
    if (_isMetadataMissing()) {
      _recoverMetadataAndLoad();
    } else {
      // Dữ liệu đủ -> Load ngay
      _initLoad();
    }

    // Context check (Logic cũ)
    if (_chapterIds.length <= 1 && widget.mangaId.isNotEmpty) {
      _fetchFullChapterContext();
    }
  }

  bool _isMetadataMissing() {
    return _currentMangaTitle.isEmpty || (_currentCoverUrl?.isEmpty ?? true);
  }

  void _initLoad() {
    // Chỉ gọi Bloc khi đã có metadata tốt nhất có thể
    _bloc.add(ReaderLoadChapter(
      _currentChapterId,
      mangaId: widget.mangaId,
      mangaTitle: _currentMangaTitle,
      coverImageUrl: _currentCoverUrl, 
      chapterNumber: _currentChapterNumberForSave(),
    ));
    
    _saveChapterProgress();
  }

  /// NEW: Khôi phục metadata từ Local History hoặc Remote API
  Future<void> _recoverMetadataAndLoad() async {
    setState(() => _isRecoveringMetadata = true);

    try {
      // Bước 1: Thử tìm trong Local History (để lấy lại bìa cũ nếu có)
      final getHistory = GetIt.instance<GetContinueReading>();
      final historyList = await getHistory();
      final historyItem = historyList.where((e) => e.mangaId == widget.mangaId).firstOrNull;

      if (historyItem != null) {
        if (_currentMangaTitle.isEmpty) _currentMangaTitle = historyItem.mangaTitle;
        if (_currentCoverUrl?.isEmpty ?? true) _currentCoverUrl = historyItem.coverImageUrl;
      }

      // Bước 2: Nếu vẫn thiếu, gọi API GetMangaDetail
      if (_isMetadataMissing()) {
        final getDetail = GetIt.instance<GetMangaDetail>();
        final manga = await getDetail(mangaId: MangaId(widget.mangaId));
        
        if (_currentMangaTitle.isEmpty) _currentMangaTitle = manga.title;
        if (_currentCoverUrl?.isEmpty ?? true) _currentCoverUrl = manga.coverImageUrl;
      }
    } catch (e) {
      debugPrint("Metadata recovery failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isRecoveringMetadata = false);
        // Sau khi cố gắng khôi phục (dù được hay không), tiến hành load
        _initLoad();
      }
    }
  }

  Future<void> _fetchFullChapterContext() async {
    if (!mounted) return;
    setState(() => _isFetchingContext = true);
    
    try {
      final listChaptersUC = GetIt.instance<ListChapters>();
      final List<Chapter> chapters = await listChaptersUC(
        mangaId: MangaId(widget.mangaId),
        ascending: true, 
        languageFilter: null,
        offset: 0,
        limit: 500, 
      );

      if (chapters.isNotEmpty && mounted) {
        final ids = chapters.map((c) => c.id.value).toList();
        final nums = chapters.map((c) => c.chapterNumber).toList();
        
        final currentId = _currentChapterId;
        final newIndex = ids.indexOf(currentId);

        setState(() {
          _chapterIds = ids;
          _chapterNumbers = nums;
          _currentIndex = newIndex != -1 ? newIndex : 0;
          _isFetchingContext = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi fetch context chapter: $e");
      if(mounted) setState(() => _isFetchingContext = false);
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String get _currentChapterId => _chapterIds[_currentIndex];
  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < _chapterIds.length - 1;

  void _saveChapterProgress() async {
    try {
      final saver = GetIt.instance<reader_uc.SaveReadProgress>();
      // Double check lần cuối trước khi lưu
      final String? safeCoverUrl = (_currentCoverUrl?.isEmpty ?? true) ? null : _currentCoverUrl;

      await saver(
        mangaId: widget.mangaId,
        mangaTitle: _currentMangaTitle,
        coverImageUrl: safeCoverUrl, 
        chapterId: _currentChapterId,
        chapterNumber: _currentChapterNumberForSave(),
      );
    } catch (_) {}
  }

  String _currentChapterNumberForSave() {
    if (_chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (_chapterNumbers!.length)) {
      final num = _chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return num;
    }
    return ""; 
  }

  String _buildChapterLabel() {
    if (_isFetchingContext && _chapterIds.length <= 1) return "Loading list...";

    if (_chapterNumbers != null &&
        _currentIndex >= 0 &&
        _currentIndex < (_chapterNumbers!.length)) {
      final num = _chapterNumbers![_currentIndex];
      if (num.isNotEmpty) return "Ch. $num";
    }
    return "Chapter";
  }

  void _handleBackToManga() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go("/manga/${widget.mangaId}");
    }
  }

  void _handlePrevChapter() {
    if (!_hasPrev) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang ở chương đầu rồi")));
      return;
    }
    setState(() => _currentIndex -= 1);
    
    // Dùng _currentMangaTitle và _currentCoverUrl đã được khôi phục/cache
    _bloc.add(ReaderLoadChapter(
      _currentChapterId,
      mangaId: widget.mangaId,
      mangaTitle: _currentMangaTitle,
      coverImageUrl: _currentCoverUrl, 
      chapterNumber: _currentChapterNumberForSave(), 
    ));
    _saveChapterProgress();
  }

  void _handleNextChapter() {
    if (!_hasNext) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hết chương rồi")));
      return;
    }
    setState(() => _currentIndex += 1);
    
    // Dùng _currentMangaTitle và _currentCoverUrl đã được khôi phục/cache
    _bloc.add(ReaderLoadChapter(
      _currentChapterId,
      mangaId: widget.mangaId,
      mangaTitle: _currentMangaTitle,
      coverImageUrl: _currentCoverUrl,
      chapterNumber: _currentChapterNumberForSave(),
    ));
    _saveChapterProgress();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu đang khôi phục metadata, hiện loading để tránh user thấy màn hình chưa sẵn sàng
    if (_isRecoveringMetadata) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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