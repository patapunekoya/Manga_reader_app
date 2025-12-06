import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';


import 'package:catalog/presentation/bloc/manga_detail_bloc.dart';
import 'package:catalog/presentation/widgets/manga_detail_view.dart';

/// ======================================================================
/// File: page/manga_detail_shell_page.dart
/// CẬP NHẬT: Thêm tham số resumeChapterId để fix lỗi compilation và logic Redirect.
/// ======================================================================
class MangaDetailShellPage extends StatefulWidget {
  final String mangaId;
  // Nhận origin từ router: 'home' | 'search' | 'library'
  final String origin;
  
  // FIX LỖI: Định nghĩa tham số resumeChapterId
  final String? resumeChapterId; 

  const MangaDetailShellPage({
    super.key,
    required this.mangaId,
    required this.origin,
    this.resumeChapterId, // <--- ĐÃ ĐỊNH NGHĨA Ở ĐÂY
  });

  @override
  State<MangaDetailShellPage> createState() => _MangaDetailShellPageState();
}

// THÊM WidgetsBindingObserver để đồng bộ trạng thái khi quay lại từ Reader
class _MangaDetailShellPageState extends State<MangaDetailShellPage> with WidgetsBindingObserver {
  // Bloc chi tiết manga (lifecycle gắn với trang này)
  late final MangaDetailBloc _bloc;
  // Lưu origin cục bộ để back đúng nơi, không phụ thuộc context về sau
  late final String _origin;
  
  // Biến cục bộ để quản lý logic redirect
  late String? _resumeChapterId;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    
    // Khởi tạo biến cục bộ từ widget params
    _resumeChapterId = widget.resumeChapterId;
    
    _bloc = GetIt.instance<MangaDetailBloc>()
      ..add(MangaDetailLoadRequested(widget.mangaId));
      
    // Đăng ký observer để đồng bộ hóa trạng thái khi quay lại
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _bloc.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // LOGIC ĐỒNG BỘ: Tải lại dữ liệu khi quay lại màn hình
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
        // Kích hoạt tải lại để đồng bộ tiến độ đọc/yêu thích
        _bloc.add(MangaDetailLoadRequested(widget.mangaId)); 
    }
  }

  /// Điều hướng "Quay lại":
  /// - Nếu còn stack để pop → pop.
  /// - Nếu không, dựa vào origin để go() về đúng tab gốc (thay thế stack).
  void _handleBack() {
    if (_hasRedirected || !context.canPop()) { 
      switch (_origin) {
        case 'search': context.go('/search'); break;
        case 'library': context.go('/library'); break;
        case 'home': default: context.go('/home'); break;
      }
      return;
    }
    context.pop();
  }

  /// Toggle Favorite (placeholder):
  void _toggleFavorite() {
    debugPrint("Toggle favorite for manga ${widget.mangaId}");
  }

  // Hàm chung để điều hướng sang Reader
  void _navigateToReader({
    required String tappedChapterId,
    required List<String> chapterIds,
    required List<String> chapterNumbers,
    required String mangaTitle,
    required String coverImageUrl,
    int pageIndex = 0,
  }) {
    final idx = chapterIds.indexOf(tappedChapterId);
    final safeIndex = idx < 0 ? 0 : idx;

    context.push(
      '/reader/$tappedChapterId'
      '?mangaId=${widget.mangaId}'
      '&page=$pageIndex'
      '&mangaTitle=${Uri.encodeComponent(mangaTitle)}'
      '&coverImageUrl=${Uri.encodeComponent(coverImageUrl)}',
      extra: {
        'chapters': chapterIds,
        'currentIndex': safeIndex,
        'chapterNumbers': chapterNumbers,
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar tối, nút back thủ công để đảm bảo back về đúng origin
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
          tooltip: 'Quay lại',
        ),
        // Tiêu đề động theo state.manga.title, chỉ rebuild khi manga thay đổi
        title: BlocBuilder<MangaDetailBloc, MangaDetailState>(
          bloc: _bloc,
          buildWhen: (p, c) => p.manga != c.manga,
          builder: (context, state) {
            final title = state.manga?.title ?? 'Chi tiết truyện';
            return Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<MangaDetailBloc, MangaDetailState>(
            builder: (context, state) {
              // Chuẩn hóa dữ liệu để truyền sang Reader
              final chapterIds = state.chapters.map((c) => c.id.value).toList();
              final chapterNumbers = state.chapters.map((c) => c.chapterNumber).toList();

              final mangaTitle = state.manga?.title ?? '';
              final coverImageUrl = state.manga?.coverImageUrl ?? '';
              
              // ==============================================================
              // LOGIC AUTO-REDIRECT CHO HISTORY LIST
              // ==============================================================
              if (_resumeChapterId != null && 
                  state.status == MangaDetailStatus.success && 
                  !_hasRedirected) 
              {
                _hasRedirected = true; 
                final tappedChapterId = _resumeChapterId!;
                final pageIndex = 0;

                Future.microtask(() {
                    _navigateToReader(
                      tappedChapterId: tappedChapterId, 
                      chapterIds: chapterIds, 
                      chapterNumbers: chapterNumbers, 
                      mangaTitle: mangaTitle, 
                      coverImageUrl: coverImageUrl,
                      pageIndex: pageIndex,
                    );
                    _resumeChapterId = null; // Vô hiệu hóa redirect sau khi dùng
                });
                
                return const Center(child: CircularProgressIndicator());
              }
              // ==============================================================

              return MangaDetailView(
                mangaId: widget.mangaId,
                // Khi người dùng chọn một chapter (hoặc tự động gọi sau khi redirect)
                onOpenChapter: (String tappedChapterId, {int pageIndex = 0}) {
                  _navigateToReader(
                    tappedChapterId: tappedChapterId, 
                    chapterIds: chapterIds, 
                    chapterNumbers: chapterNumbers, 
                    mangaTitle: mangaTitle, 
                    coverImageUrl: coverImageUrl,
                    pageIndex: pageIndex,
                  );
                },
                onToggleFavorite: _toggleFavorite,
              );
            },
          ),
        ),
      ),
    );
  }
}