part of 'manga_detail_bloc.dart';

/// =======================================================================
/// EVENT DEFINITIONS for MangaDetailBloc
///
/// Mục đích:
///   - Định nghĩa tất cả các sự kiện (Event) mà MangaDetailBloc có thể xử lý.
///   - Mỗi Event đại diện cho một hành động hoặc yêu cầu từ UI.
///
/// Kiến trúc:
///   - Thuộc tầng Presentation (BLoC).
///   - Bloc lắng nghe Event -> xử lý -> cập nhật State.
///
/// Lưu ý:
///   - Tất cả Event extends Equatable để so sánh tối ưu, tránh rebuild không cần thiết.
/// =======================================================================

abstract class MangaDetailEvent extends Equatable {
  const MangaDetailEvent();

  @override
  List<Object?> get props => [];
}

/// =======================================================================
/// Event: MangaDetailLoadRequested
///
/// Khi nào chạy:
///   - Khi user mở trang chi tiết manga.
///   - Router hoặc ShellPage sẽ dispatch sự kiện này.
///
/// Chức năng:
///   - Reset state.
///   - Gọi UseCase lấy chi tiết manga + tải chương trang đầu.
/// =======================================================================
class MangaDetailLoadRequested extends MangaDetailEvent {
  final String mangaId;
  const MangaDetailLoadRequested(this.mangaId);

  @override
  List<Object?> get props => [mangaId];
}

/// =======================================================================
/// Event: MangaDetailToggleSort
///
/// Khi nào chạy:
///   - Khi user bấm nút đổi thứ tự (asc <-> desc).
///
/// Chức năng:
///   - Lật state.ascending.
///   - Reload danh sách chapter từ đầu.
/// =======================================================================
class MangaDetailToggleSort extends MangaDetailEvent {
  const MangaDetailToggleSort();
}

/// =======================================================================
/// Event: MangaDetailLoadMoreChapters
///
/// Khi nào chạy:
///   - Khi user kéo xuống dưới danh sách chương.
///   - Khi UI phát hiện còn nhiều trang dữ liệu.
/// 
/// Chức năng:
///   - Gọi listChapters(offset tăng dần).
///   - Ghép dữ liệu vào state.chapters.
/// =======================================================================
class MangaDetailLoadMoreChapters extends MangaDetailEvent {
  const MangaDetailLoadMoreChapters();
}

/// =======================================================================
/// Event: MangaDetailFavoriteToggled
///
/// Khi nào chạy:
///   - Khi user bấm nút "favorite" trong MangaDetailView.
///
/// Chức năng:
///   - Optimistic update invert isFavorite.
///   - Gọi ToggleFavorite UseCase.
///   - Nếu lỗi, revert lại.
/// =======================================================================
class MangaDetailFavoriteToggled extends MangaDetailEvent {
  const MangaDetailFavoriteToggled();
}

/// =======================================================================
/// Event: MangaDetailRefreshFavorite
///
/// Khi nào chạy:
///   - Khi UI yêu cầu đồng bộ lại trạng thái favorite (ví dụ: khi comeback).
///
/// Chức năng:
///   - Gọi GetFavorites → thiết lập lại đúng isFavorite.
/// =======================================================================
class MangaDetailRefreshFavorite extends MangaDetailEvent {
  const MangaDetailRefreshFavorite();
}

/// =======================================================================
/// Event: MangaDetailSelectLanguage
///
/// Khi nào chạy:
///   - Khi user chọn một ngôn ngữ cụ thể ở bộ lọc dropdown.
///
/// Chức năng:
///   - Nếu language == null → chế độ ALL.
///   - Reset danh sách chương và tải lại trang đầu với filter mới.
/// =======================================================================
class MangaDetailSelectLanguage extends MangaDetailEvent {
  final String? language;
  const MangaDetailSelectLanguage(this.language);

  @override
  List<Object?> get props => [language];
}
