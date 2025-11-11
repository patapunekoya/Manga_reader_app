part of 'favorites_bloc.dart';

/// ============================================================================
/// FavoritesStatus
/// ============================================================================
/// Trạng thái tổng quát của FavoritesBloc:
/// - initial: chưa làm gì, mới khởi tạo.
/// - loading: đang fetch dữ liệu từ local (Hive).
/// - success: tải thành công, có dữ liệu.
/// - failure: lỗi xảy ra (thường là lỗi đọc Hive).
/// ============================================================================
enum FavoritesStatus { initial, loading, success, failure }

/// ============================================================================
/// FavoritesState
/// ============================================================================
/// State quản lý toàn bộ thông tin của màn Favorites:
/// - status: trạng thái hiện tại.
/// - items: danh sách manga được đánh dấu yêu thích.
/// - errorMessage: lỗi (nếu có).
///
/// Lưu ý:
/// - Dùng `Equatable` để tránh UI build lại không cần thiết.
/// - Có copyWith() để update từng phần mà không tạo state mới toàn bộ.
/// ============================================================================
class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteItem> items;
  final String? errorMessage;

  const FavoritesState({
    required this.status,
    required this.items,
    required this.errorMessage,
  });

  /// Trạng thái khởi tạo: rỗng và chưa fetch gì.
  const FavoritesState.initial()
      : status = FavoritesStatus.initial,
        items = const [],
        errorMessage = null;

  /// Hàm copyWith:
  /// Cho phép cập nhật một trường trong state mà giữ nguyên các trường khác.
  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteItem>? items,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        errorMessage,
      ];
}
