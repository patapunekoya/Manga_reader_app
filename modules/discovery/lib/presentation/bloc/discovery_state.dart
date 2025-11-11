// lib/presentation/bloc/discovery_state.dart
//
// -----------------------------------------------------------------------------
// DiscoveryState
// -----------------------------------------------------------------------------
// Chức năng file:
// - Khai báo toàn bộ “trạng thái” (State) mà DiscoveryBloc có thể phát ra.
// - State là dữ liệu đầu ra sau khi Bloc xử lý event và chuẩn bị để UI render.
//
// Tại sao cần file state riêng?
// - Theo chuẩn BLoC, tách event/state ra giúp code rõ ràng, maintain dễ,
//   và DiscoveryBloc chỉ tập trung xử lý logic.
// - UI chỉ cần listen(state) và build lại giao diện.
//
// Khái niệm quan trọng:
// - State trong BLoC luôn là immutable (không được sửa trực tiếp).
// - copyWith() dùng để tạo state mới dựa trên state cũ.
// - Equatable giúp so sánh giá trị các field, tránh rebuild UI dư thừa.
//
// State ở đây quản lý 3 nhóm dữ liệu chính của module Discovery:
// 1) trending manga
// 2) latest updates
// 3) trạng thái (đang load / lỗi / thành công)
// -----------------------------------------------------------------------------

part of 'discovery_bloc.dart';

/// ---------------------------------------------------------------------------
/// DiscoveryStatus
/// ---------------------------------------------------------------------------
/// Enum mô tả "trạng thái logic" hiện tại của DiscoveryBloc.
/// Dùng bởi UI để quyết định hiển thị loading/error/success.
/// - initial: Bloc mới tạo, chưa fetch gì.
/// - loading: đang gọi API (fetch trending + latest).
/// - success: đã fetch xong và có dữ liệu.
/// - failure: có lỗi khi fetch.
/// ---------------------------------------------------------------------------
enum DiscoveryStatus { initial, loading, success, failure }

class DiscoveryState extends Equatable {
  /// Status hiện tại của bloc.
  final DiscoveryStatus status;

  /// Danh sách manga trending (top follow trên MangaDex).
  final List<FeedItem> trending;

  /// Danh sách manga mới cập nhật (latest updates).
  final List<FeedItem> latest;

  /// Thông điệp lỗi (nếu có), để UI hiển thị.
  final String? errorMessage;

  const DiscoveryState({
    required this.status,
    required this.trending,
    required this.latest,
    required this.errorMessage,
  });

  /// State khởi tạo mặc định khi Bloc mới được tạo.
  /// - chưa có data
  /// - không có lỗi
  /// - trending/latest = rỗng
  const DiscoveryState.initial()
      : status = DiscoveryStatus.initial,
        trending = const [],
        latest = const [],
        errorMessage = null;

  /// -------------------------------------------------------------------------
  /// copyWith
  /// -------------------------------------------------------------------------
  /// Tạo một state mới dựa trên state hiện tại.
  /// Đây là tiêu chuẩn trong BLoC để tránh thay đổi trực tiếp state.
  /// Ví dụ:
  /// emit(state.copyWith(status: DiscoveryStatus.loading))
  ///
  /// Các tham số null => giữ giá trị cũ.
  /// -------------------------------------------------------------------------
  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<FeedItem>? trending,
    List<FeedItem>? latest,
    String? errorMessage,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      trending: trending ?? this.trending,
      latest: latest ?? this.latest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Equatable giúp Flutter biết 2 state giống nhau -> không rebuild UI vô lý.
  @override
  List<Object?> get props => [
        status,
        trending,
        latest,
        errorMessage,
      ];
}
