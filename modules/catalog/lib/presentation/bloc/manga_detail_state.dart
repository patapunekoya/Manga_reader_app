part of 'manga_detail_bloc.dart';

/// =======================================================================
/// STATE DEFINITIONS for MangaDetailBloc
///
/// Đây là toàn bộ "mô tả trạng thái" mà trang Chi Tiết Manga (MangaDetail)
/// cần để hoạt động.
/// 
/// UI sẽ rebuild khi state thay đổi nhờ Equatable.
///
/// Các nhóm trạng thái:
///   - Trạng thái màn tổng thể (loading | success | failure)
///   - Thông tin manga (id, entity Manga)
///   - Danh sách chương + phân trang
///   - Thông tin sort (ascending)
///   - Bộ lọc ngôn ngữ
///   - Lỗi (errorMessage)
///
/// Trạng thái state được bất biến (immutable).
/// Mọi thay đổi đều đi qua copyWith().
/// =======================================================================

enum MangaDetailStatus {
  /// Lần đầu vào bloc, chưa load gì
  initial,

  /// Đang tải toàn bộ màn manga detail (manga info + chapters)
  loading,

  /// Tải xong thành công
  success,

  /// Gặp lỗi — thường dùng để hiển thị thông báo lỗi
  failure,

  /// Đang tải lại danh sách chương (khi đổi sort hoặc đổi language)
  loadingChapters,

  /// Đang load thêm chương (khi scroll load-more)
  loadingMoreChapters,
}

class MangaDetailState extends Equatable {
  /// Trạng thái màn hình hiện tại
  final MangaDetailStatus status;

  /// Id manga hiện đang hiển thị
  final String mangaId;

  /// Entity Manga (đã map từ domain)
  final Manga? manga;

  /// Danh sách chapter
  final List<Chapter> chapters;

  /// Thứ tự sort: true = ascending
  final bool ascending;

  /// Có còn dữ liệu để load-more không
  final bool hasMoreChapters;

  /// Offset hiện tại khi phân trang
  final int chapterOffset;

  /// Danh sách ngôn ngữ lấy từ chapter (ví dụ ['en','vi'])
  final List<String> availableLanguages;

  /// Ngôn ngữ đang chọn; null = ALL
  final String? selectedLanguage;

  /// Thông tin lỗi (nếu có)
  final String? errorMessage;

  /// =====================================================================
  /// Constructor chuẩn — yêu cầu đầy đủ mọi field
  /// =====================================================================
  const MangaDetailState({
    required this.status,
    required this.mangaId,
    required this.manga,
    required this.chapters,
    required this.ascending,
    required this.hasMoreChapters,
    required this.chapterOffset,
    required this.availableLanguages,
    required this.selectedLanguage,
    required this.errorMessage,
  });

  /// =====================================================================
  /// State khởi tạo — dùng khi bloc được tạo ra lần đầu
  /// =====================================================================
  const MangaDetailState.initial()
      : status = MangaDetailStatus.initial,
        mangaId = '',
        manga = null,
        chapters = const [],
        ascending = true,
        hasMoreChapters = true,
        chapterOffset = 0,
        availableLanguages = const [],
        selectedLanguage = null,
        errorMessage = null;

  /// =====================================================================
  /// copyWith:
  /// Cho phép cập nhật từng phần của state mà không mutating dữ liệu cũ.
  /// UI rebuild dựa theo state mới.
  /// =====================================================================
  MangaDetailState copyWith({
    MangaDetailStatus? status,
    String? mangaId,
    Manga? manga,
    List<Chapter>? chapters,
    bool? ascending,
    bool? hasMoreChapters,
    int? chapterOffset,
    List<String>? availableLanguages,
    String? selectedLanguage,
    String? errorMessage,
  }) {
    return MangaDetailState(
      status: status ?? this.status,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      ascending: ascending ?? this.ascending,
      hasMoreChapters: hasMoreChapters ?? this.hasMoreChapters,
      chapterOffset: chapterOffset ?? this.chapterOffset,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Equatable — để BLoC biết khi nào cần rebuild UI
  @override
  List<Object?> get props => [
        status,
        mangaId,
        manga,
        chapters,
        ascending,
        hasMoreChapters,
        chapterOffset,
        availableLanguages,
        selectedLanguage,
        errorMessage,
      ];
}
