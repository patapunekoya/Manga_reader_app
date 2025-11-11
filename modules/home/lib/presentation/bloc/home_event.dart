// -----------------------------------------------------------------------------
// home/presentation/bloc/home_event.dart
// -----------------------------------------------------------------------------
// File này định nghĩa các sự kiện (Event) mà HomeBloc có thể nhận.
//
// Trong mô hình Bloc:
//   - Event = thứ mà UI hoặc hệ thống "gửi vào" để yêu cầu hành động.
//   - State  = kết quả mà Bloc "xuất ra" cho UI render.
//
// Ở đây HomeBloc chỉ có 2 event:
//   1) HomeLoadRequested     → dùng để load dữ liệu lần đầu khi mở màn Home.
//   2) HomeRefreshRequested  → dùng để kéo refresh hoặc làm mới dữ liệu.
//
// Hai event đều giống nhau về chức năng (đều trigger _onLoad() trong Bloc).
// Nhưng tách riêng để UI có thể phân biệt rõ mục đích ở mức semantic.
// -----------------------------------------------------------------------------

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  // Dùng Equatable giúp Bloc biết hai event giống nhau để hạn chế rebuild dư thừa.
  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// HomeLoadRequested
//
// Event này được bắn ra khi:
// - Màn hình Home vừa khởi tạo (initState)
// - App chuyển tab Home và muốn load data ngay lập tức.
//
// HomeBloc sẽ:
//   → set state = loading
//   → gọi BuildHomeVM() để gom dữ liệu
//   → emit success hoặc failure.
// ---------------------------------------------------------------------------
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

// ---------------------------------------------------------------------------
// HomeRefreshRequested
//
// Event này được dùng khi người dùng kéo xuống "pull-to-refresh" hoặc bấm nút
// refresh ở UI.
//
// Vì logic load và refresh giống nhau nên home_bloc.dart map cả hai về _onLoad().
// Tuy nhiên tách event riêng giúp UI gọi cho đúng nghĩa vụ.
//
// VD:
//   RefreshIndicator(
//     onRefresh: () async {
//       context.read<HomeBloc>().add(const HomeRefreshRequested());
//     },
//   );
//
// ---------------------------------------------------------------------------
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}
