import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:catalog/presentation/bloc/manga_detail_bloc.dart';
import 'package:catalog/presentation/widgets/manga_detail_view.dart';

/// ======================================================================
/// File: page/manga_detail_shell_page.dart
/// Mục đích:
///   - “Shell” mỏng cho màn Chi tiết Manga.
///   - Lấy MangaDetailBloc từ DI, trigger load theo mangaId.
///   - Điều hướng ngược về đúng tab nguồn (home/search/library) khi back.
///   - Điều hướng tới Reader khi chọn một chapter trong MangaDetailView.
/// Dòng chảy:
///   UI (MangaDetailView) -> onOpenChapter(...) -> push /reader/:chapterId + extra
///   Khởi tạo: add(MangaDetailLoadRequested(mangaId)) -> Bloc phát state (manga, chapters)
/// Lưu ý:
///   - Không đọc context trong initState để tránh phụ thuộc Router lúc init.
///   - Mọi tham số điều hướng encode an toàn (Uri.encodeComponent).
///   - Truyền 'chapters', 'currentIndex', 'chapterNumbers' qua state.extra để Reader có đủ ngữ cảnh.
/// ======================================================================
class MangaDetailShellPage extends StatefulWidget {
  final String mangaId;
  // Nhận origin từ router: 'home' | 'search' | 'library'
  final String origin;

  const MangaDetailShellPage({
    super.key,
    required this.mangaId,
    required this.origin,
  });

  @override
  State<MangaDetailShellPage> createState() => _MangaDetailShellPageState();
}

class _MangaDetailShellPageState extends State<MangaDetailShellPage> {
  // Bloc chi tiết manga (lifecycle gắn với trang này)
  late final MangaDetailBloc _bloc;
  // Lưu origin cục bộ để back đúng nơi, không phụ thuộc context về sau
  late final String _origin;

  @override
  void initState() {
    super.initState();
    _origin = widget.origin; // không đọc context ở đây nữa
    _bloc = GetIt.instance<MangaDetailBloc>()
      ..add(MangaDetailLoadRequested(widget.mangaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// Điều hướng "Quay lại":
  /// - Nếu còn stack để pop → pop.
  /// - Nếu không, dựa vào origin để go() về đúng tab gốc (thay thế stack).
  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    switch (_origin) {
      case 'search':
        context.go('/search');
        break;
      case 'library':
        context.go('/library');
        break;
      case 'home':
      default:
        context.go('/home');
        break;
    }
  }

  /// Toggle Favorite (placeholder):
  /// - Thực thi UseCase/Bloc thật ở phiên bản sau.
  void _toggleFavorite() {
    debugPrint("Toggle favorite for manga ${widget.mangaId}");
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

              return MangaDetailView(
                mangaId: widget.mangaId,
                // Khi người dùng chọn một chapter
                onOpenChapter: (String tappedChapterId, {int pageIndex = 0}) {
                  // Tìm vị trí chapter trong danh sách để Reader biết currentIndex
                  final idx = chapterIds.indexOf(tappedChapterId);
                  final safeIndex = idx < 0 ? 0 : idx;

                  // Điều hướng sang Reader:
                  // - Path param: :chapterId
                  // - Query: mangaId, page, mangaTitle, coverImageUrl
                  // - Extra: list chapterIds, currentIndex, chapterNumbers
                  context.push(
                    '/reader/$tappedChapterId'
                    '?mangaId=${widget.mangaId}'
                    '&page=$pageIndex'
                    '&mangaTitle=${Uri.encodeComponent(mangaTitle)}'
                    '&coverImageUrl=${Uri.encodeComponent(coverImageUrl)}',
                    extra: {
                      'chapters': chapterIds,
                      'currentIndex': safeIndex,
                      'chapterNumbers': chapterNumbers, // có thể là int/String mixture → Reader ép String
                    },
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
