// -----------------------------------------------------------------------------
// home/presentation/bloc/home_state.dart
// -----------------------------------------------------------------------------
// File này định nghĩa STATE của HomeBloc.
//
// Trong mô hình Bloc:
//   - State = dữ liệu UI cần hiển thị tại 1 thời điểm.
//   - Bloc sẽ emit State mới mỗi khi logic xử lý xong.
//
// HomeState giữ 3 phần dữ liệu chính của màn Home:
//   1) continueReading  → danh sách truyện đang đọc dở (local)
//   2) recommended      → danh sách trending từ Discovery (carousel)
//   3) latestUpdates    → manga mới cập nhật (list dọc)
//
// Ngoài ra còn có:
//   - status        → để UI biết đang loading / success / failure
//   - errorMessage  → mô tả lỗi (nếu có)
// 
// State này được BuildHomeVM dựng sẵn data và HomeBloc emit ra.
// -----------------------------------------------------------------------------

import 'package:equatable/equatable.dart';
import 'package:home/domain/entities/home_vm.dart';
import 'package:discovery/domain/entities/feed_item.dart';

// -----------------------------------------------------------------------------
// HomeStatus: mô tả trạng thái hiện tại của HomeBloc
//
// - initial: chưa load gì cả
// - loading: đang gọi API / đang build data
// - success: đã load xong → UI render dữ liệu
// - failure: load lỗi → UI hiển thị error
// -----------------------------------------------------------------------------
enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

// -----------------------------------------------------------------------------
// HomeState: toàn bộ dữ liệu mà Home screen cần để render.
//
// continueReading  → list item “Đọc dở” (lấy từ local / Hive)
// recommended      → trending (từ Discovery)
// latestUpdates    → manga mới cập nhật
//
// errorMessage → chỉ dùng khi failure
// -----------------------------------------------------------------------------
class HomeState extends Equatable {
  final HomeStatus status;
  final List<ContinueReadingItemVM> continueReading;
  final List<FeedItem> recommended;
  final List<FeedItem> latestUpdates;
  final String? errorMessage;

  const HomeState({
    required this.status,
    required this.continueReading,
    required this.recommended,
    required this.latestUpdates,
    required this.errorMessage,
  });

  // ---------------------------------------------------------------------------
  // State mặc định khi HomeBloc mới khởi tạo
  // ---------------------------------------------------------------------------
  const HomeState.initial()
      : status = HomeStatus.initial,
        continueReading = const [],
        recommended = const [],
        latestUpdates = const [],
        errorMessage = null;

  // ---------------------------------------------------------------------------
  // copyWith: giúp Bloc tạo state mới mà không phải clone thủ công.
  //
  // VD trong HomeBloc:
  //   emit(state.copyWith(status: HomeStatus.loading));
  //
  // copyWith sẽ giữ nguyên những field không truyền vào.
  // ---------------------------------------------------------------------------
  HomeState copyWith({
    HomeStatus? status,
    List<ContinueReadingItemVM>? continueReading,
    List<FeedItem>? recommended,
    List<FeedItem>? latestUpdates,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      continueReading: continueReading ?? this.continueReading,
      recommended: recommended ?? this.recommended,
      latestUpdates: latestUpdates ?? this.latestUpdates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ---------------------------------------------------------------------------
  // Equatable: giúp Flutter biết khi nào state thực sự thay đổi,
  // tránh rebuild UI không cần thiết.
  // ---------------------------------------------------------------------------
  @override
  List<Object?> get props => [
        status,
        continueReading,
        recommended,
        latestUpdates,
        errorMessage,
      ];
}
