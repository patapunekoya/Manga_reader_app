part of 'history_bloc.dart';

/// ============================================================================
/// HistoryEvent
/// ----------------------------------------------------------------------------
/// Đây là tập hợp các sự kiện (Event) mà HistoryBloc có thể nhận.
/// UI sẽ dispatch các event này để yêu cầu Bloc xử lý.
/// - Sử dụng Equatable để so sánh giá trị, giúp tối ưu rebuild UI.
/// - Các event không chứa state nội bộ, nên props = [].
/// ============================================================================

@immutable
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  /// Equatable yêu cầu override props để xác định các field dùng so sánh.
  /// Vì event không chứa dữ liệu bổ sung -> props rỗng.
  @override
  List<Object?> get props => [];
}

/// ----------------------------------------------------------------------------
/// HistoryLoadRequested
/// ----------------------------------------------------------------------------
/// Event yêu cầu HistoryBloc load danh sách lịch sử đọc.
/// - Thường được gọi trong initState() của HistoryPage hoặc khi user kéo refresh.
/// ----------------------------------------------------------------------------
class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

/// ----------------------------------------------------------------------------
/// HistoryClearAllRequested
/// ----------------------------------------------------------------------------
/// Event yêu cầu xóa sạch toàn bộ lịch sử đọc.
/// - UI nên hiển thị hộp thoại confirm trước khi dispatch event này.
/// - Sau khi xóa, HistoryBloc sẽ load lại dữ liệu (thường ra list rỗng).
/// ----------------------------------------------------------------------------
class HistoryClearAllRequested extends HistoryEvent {
  const HistoryClearAllRequested();
}
