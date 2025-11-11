// lib/presentation/bloc/discovery_bloc.dart
//
// -----------------------------------------------------------------------------
// DiscoveryBloc
// -----------------------------------------------------------------------------
// Chức năng file:
// - Định nghĩa BLoC quản lý dữ liệu "Khám phá" (Discovery) cho màn hình Home.
// - Khi nhận sự kiện load, bloc gọi 2 usecase: GetTrending và GetLatestUpdates,
//   sau đó nhét kết quả vào state để UI render.
// - Trạng thái có 3 nhánh chính: loading / success / failure.
//
// Vì sao tách usecase ra khỏi BLoC?
// - BLoC chỉ điều phối luồng và state. Logic gọi API, phân trang, policy…
//   gói trong usecase/repository → dễ test, dễ thay thế nguồn dữ liệu.
//
// Luồng hoạt động (MVP):
// 1) UI dispatch `DiscoveryLoadEvent()` khi mở Home.
// 2) Bloc set state.loading.
// 3) Bloc gọi _getTrending(cursor: FeedCursor(0,10)) và
//    _getLatest(cursor: FeedCursor(0,10)) (chạy lần lượt).
// 4) Thành công → state.success với 2 list; Lỗi → state.failure + errorMessage.
//
// Mở rộng sau:
// - Load-more cho trending/latest (thêm event + giữ cursor trong state).
// - Refresh độc lập từng danh sách.
// -----------------------------------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

// Barrel export của module discovery: cung cấp usecase GetTrending/GetLatestUpdates
import '../../../discovery.dart'
    show GetTrending, GetLatestUpdates; // từ barrel

// Entity và VO cho feed + phân trang
import '../../../domain/entities/feed_item.dart';
import '../../../domain/value_objects/feed_cursor.dart';

// Tách phần event/state ra file riêng để gọn gàng
part 'discovery_event.dart';
part 'discovery_state.dart';

/// ---------------------------------------------------------------------------
/// DiscoveryBloc
/// ---------------------------------------------------------------------------
/// Nhiệm vụ:
/// - Nhận `DiscoveryLoadEvent` từ UI.
/// - Gọi 2 usecase để lấy danh sách:
///     + trending (manga phổ biến)
///     + latest   (manga vừa cập nhật)
/// - Cập nhật `DiscoveryState` cho UI.
///
/// Ghi chú:
/// - Ở phiên bản này chỉ fetch trang đầu (offset=0, limit=10).
/// - Nếu cần tối ưu UX: có thể chạy 2 usecase song song (Future.wait),
///   nhưng cũng nên cân nhắc rate-limit và error handling tách biệt.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  // Usecase lấy dữ liệu trending
  final GetTrending _getTrending;
  // Usecase lấy dữ liệu latest updates
  final GetLatestUpdates _getLatest;

  /// Inject usecase qua constructor (sử dụng DI như GetIt ở bootstrap).
  DiscoveryBloc({
    required GetTrending getTrending,
    required GetLatestUpdates getLatest,
  })  : _getTrending = getTrending,
        _getLatest = getLatest,
        // State khởi tạo: `DiscoveryState.initial()`
        super(const DiscoveryState.initial()) {
    // Đăng ký handler cho sự kiện load
    on<DiscoveryLoadEvent>(_onLoad);
  }

  /// Handler chính cho `DiscoveryLoadEvent`.
  /// - Set trạng thái `loading`.
  /// - Gọi 2 usecase với FeedCursor(offset:0, limit:10).
  /// - Thành công → `success` + gán lists; Lỗi → `failure` + errorMessage.
  Future<void> _onLoad(
    DiscoveryLoadEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    // Bước 1: đẩy state sang loading để UI show skeleton/spinner
    emit(state.copyWith(
      status: DiscoveryStatus.loading,
    ));

    try {
      // Bước 2: gọi usecase. Có thể gộp Future.wait nếu muốn song song.
      final trendingItems = await _getTrending(
        cursor: const FeedCursor(offset: 0, limit: 10),
      );
      final latestItems = await _getLatest(
        cursor: const FeedCursor(offset: 0, limit: 10),
      );

      // Bước 3: thành công → đưa dữ liệu vào state
      emit(state.copyWith(
        status: DiscoveryStatus.success,
        trending: trendingItems,
        latest: latestItems,
        errorMessage: null,
      ));
    } catch (e) {
      // Bước 4: lỗi → đưa state.failure kèm thông báo
      emit(state.copyWith(
        status: DiscoveryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
