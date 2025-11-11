// lib/presentation/bloc/discovery_event.dart
//
// -----------------------------------------------------------------------------
// DiscoveryEvent
// -----------------------------------------------------------------------------
// Chức năng file:
// - Khai báo toàn bộ các "sự kiện" (Event) mà DiscoveryBloc có thể nhận.
// - Event là tín hiệu UI hoặc hệ thống gửi vào BLoC để yêu cầu hành động mới.
//
// Vì sao tách file event?
// - Theo chuẩn BLoC, event và state được tách thành file riêng giúp code gọn,
//   dễ đọc, dễ maintain, và tránh file discovery_bloc.dart bị phình to.
// - Mỗi event đại diện cho một action duy nhất có thể xảy ra.
//
// Kiến thức cơ bản:
// - DiscoveryEvent extends Equatable để hỗ trợ so sánh giá trị thay vì so sánh
//   reference, giúp Bloc tránh rebuild không cần thiết.
// -----------------------------------------------------------------------------

part of 'discovery_bloc.dart';

@immutable
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// ---------------------------------------------------------------------------
/// DiscoveryLoadEvent
/// ---------------------------------------------------------------------------
/// Ý nghĩa:
/// - Đây là "event khởi động" để yêu cầu DiscoveryBloc load 2 danh sách:
///   + trending manga
///   + latest updates
///
/// Khi nào được bắn?
/// - Khi HomeScreen mở.
/// - Hoặc khi người dùng pull-to-refresh (nếu ông implement sau).
///
/// Đây là MVP event duy nhất của DiscoveryBloc.
/// Có thể mở rộng: DiscoveryLoadMoreTrending, DiscoveryRefresh, v.v.
/// ---------------------------------------------------------------------------
class DiscoveryLoadEvent extends DiscoveryEvent {
  const DiscoveryLoadEvent();
}
