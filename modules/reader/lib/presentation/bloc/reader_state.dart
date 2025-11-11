// modules/reader/lib/presentation/bloc/reader_state.dart
//
// Đây là toàn bộ STATE của ReaderBloc.
// State ghi lại TẤT CẢ thông tin cần thiết để màn Reader hiển thị đúng:
//
// - status: loading / success / failure
// - chapterId: đang đọc chapter nào
// - pages: danh sách PageImage (ảnh thật của từng trang)
// - currentPage: đang đứng ở trang thứ mấy (PageIndex VO)
// - mangaId/mangaTitle/coverImageUrl/chapterNumber: metadata
//   để lưu ReadingProgress (theo CHAPTER)
// - errorMessage: hiển thị khi API fail
//
// Lưu ý: CHAPTER-ONLY progress nghĩa là chỉ lưu chapter gần nhất,
// KHÔNG lưu pageIndex.
//

part of 'reader_bloc.dart';

/// Trạng thái tổng của Reader
enum ReaderStatus {
  initial,  // mới tạo BLoC, chưa load
  loading,  // đang gọi API getChapterPages
  success,  // load thành công -> có pages
  failure,  // lỗi API / lỗi parse
}

class ReaderState extends Equatable {
  // =======================================================================
  // STATUS
  // =======================================================================
  final ReaderStatus status;

  // =======================================================================
  // THÔNG TIN CHAPTER HIỆN TẠI
  // =======================================================================

  /// ID của chapter đang đọc.
  /// ReaderBloc nhận từ event ReaderLoadChapter.
  final String chapterId;

  /// Danh sách PageImage đã map từ JSON /at-home.
  /// Mỗi PageImage = index + imageUrl.
  final List<PageImage> pages;

  /// Trang hiện tại (dạng ValueObject PageIndex).
  /// UI sẽ dùng currentPage.value để hiển thị "1 / N".
  final PageIndex currentPage;

  // =======================================================================
  // METADATA LƯU PROGRESS
  // (được truyền từ ReaderLoadChapter event)
  // -> đủ để lưu `ReadingProgress` trong Library module
  // =======================================================================

  /// MangaId để biết đang đọc truyện nào.
  final String mangaId;

  /// Tên truyện để hiển thị trong HistoryList.
  final String mangaTitle;

  /// Hàm nội suy: ảnh bìa -> để hiện trong History / Library.
  final String coverImageUrl;

  /// Số chapter dạng “23” hoặc “12.1”.
  /// Dùng để hiển thị trong lịch sử đọc.
  final String chapterNumber;

  // =======================================================================
  // ERROR (nếu có)
  // =======================================================================
  final String? errorMessage;

  // =======================================================================
  // CONSTRUCTOR CHÍNH
  // =======================================================================
  const ReaderState({
    required this.status,
    required this.chapterId,
    required this.pages,
    required this.currentPage,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverImageUrl,
    required this.chapterNumber,
    required this.errorMessage,
  });

  // =======================================================================
  // INITIAL STATE
  // =======================================================================
  const ReaderState.initial()
      : status = ReaderStatus.initial,
        chapterId = '',
        pages = const [],
        currentPage = const PageIndex(0),
        mangaId = '',
        mangaTitle = '',
        coverImageUrl = '',
        chapterNumber = '',
        errorMessage = null;

  // =======================================================================
  // COPYWITH (immutable state)
  // =======================================================================
  ReaderState copyWith({
    ReaderStatus? status,
    String? chapterId,
    List<PageImage>? pages,
    PageIndex? currentPage,
    String? mangaId,
    String? mangaTitle,
    String? coverImageUrl,
    String? chapterNumber,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      chapterId: chapterId ?? this.chapterId,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // =======================================================================
  // PROPS (Equatable)
  // =======================================================================
  @override
  List<Object?> get props => [
        status,
        chapterId,
        pages,
        currentPage,
        mangaId,
        mangaTitle,
        coverImageUrl,
        chapterNumber,
        errorMessage,
      ];
}
