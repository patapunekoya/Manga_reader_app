part of 'history_bloc.dart';

/// ============================================================================
/// HistoryStatus
/// ----------------------------------------------------------------------------
/// Enum mô tả trạng thái hiện tại của HistoryBloc:
/// - initial: chưa load gì
/// - loading: đang tải dữ liệu từ local storage (Hive)
/// - success: tải thành công -> có thể hiển thị danh sách
/// - failure: xảy ra lỗi -> show thông báo lỗi
/// ============================================================================
enum HistoryStatus { initial, loading, success, failure }

/// ============================================================================
/// HistoryState
/// ----------------------------------------------------------------------------
/// State chứa toàn bộ dữ liệu mà UI cần để render màn “Lịch sử đọc”:
/// - status: xem Bloc đang ở giai đoạn nào
/// - history: danh sách ReadingProgress (mỗi item là manga + chương gần nhất)
/// - errorMessage: thông báo lỗi (nếu có)
///
/// Dùng Equatable để tránh rebuild UI không cần thiết.
/// ============================================================================
class HistoryState extends Equatable {
  /// Trạng thái hiện tại của Bloc
  final HistoryStatus status;

  /// Danh sách progress đọc (sort theo savedAt giảm dần trong Repository)
  final List<ReadingProgress> history;

  /// Tin nhắn lỗi (nullable). Chỉ set khi status = failure.
  final String? errorMessage;

  const HistoryState({
    required this.status,
    required this.history,
    this.errorMessage,
  });

  /// Trạng thái khởi tạo ban đầu:
  /// - status = initial
  /// - history rỗng
  /// - không có lỗi
  const HistoryState.initial()
      : status = HistoryStatus.initial,
        history = const [],
        errorMessage = null;

  /// --------------------------------------------------------------------------
  /// copyWith
  /// --------------------------------------------------------------------------
  /// Giúp update một phần state mà không cần tạo lại toàn bộ.
  /// Các field không truyền vào sẽ giữ nguyên giá trị cũ.
  /// --------------------------------------------------------------------------
  HistoryState copyWith({
    HistoryStatus? status,
    List<ReadingProgress>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      // errorMessage được override luôn (kể cả null),
      // vì một số tình huống refresh có thể cần clear error.
      errorMessage: errorMessage,
    );
  }

  /// --------------------------------------------------------------------------
  /// Equatable props
  /// --------------------------------------------------------------------------
  /// Dùng để xác định state có thay đổi hay không, giúp tránh render thừa.
  /// --------------------------------------------------------------------------
  @override
  List<Object?> get props => [
        status,
        history,
        errorMessage,
      ];
}
