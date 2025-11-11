part of 'favorites_bloc.dart';

/// ============================================================================
/// FavoritesEvent
/// ============================================================================
/// Tập hợp các "tín hiệu" mà UI gửi lên FavoritesBloc.
/// - Không chứa logic.
/// - Chỉ mang dữ liệu cần thiết cho Bloc.
/// ============================================================================

/// Base class của mọi event.
/// Dùng Equatable để Bloc so sánh event dễ dàng (giảm rebuild thừa).
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Event: yêu cầu tải danh sách favorites lần đầu.
/// Thường gọi khi mở màn hình "Favorites".
class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

/// Event: yêu cầu refresh dữ liệu.
/// Thường dùng khi kéo để làm mới (pull-to-refresh).
class FavoritesRefreshRequested extends FavoritesEvent {
  const FavoritesRefreshRequested();
}

/// Event: toggle trạng thái yêu thích:
/// - Nếu đang chưa yêu thích -> thêm.
/// - Nếu đang yêu thích -> bỏ.
/// 
/// UI sẽ truyền vào:
/// - mangaId: id truyện
/// - title: tên truyện (để lưu local)
/// - coverImageUrl: ảnh bìa (nullable)
class FavoritesToggleRequested extends FavoritesEvent {
  final String mangaId;
  final String title;
  final String? coverImageUrl;

  const FavoritesToggleRequested({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        mangaId,
        title,
        coverImageUrl,
      ];
}
