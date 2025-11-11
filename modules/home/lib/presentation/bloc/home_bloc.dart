// -----------------------------------------------------------------------------
// home/presentation/bloc/home_bloc.dart
// -----------------------------------------------------------------------------
// File này định nghĩa HomeBloc – bộ não xử lý dữ liệu cho màn hình Home.
//
// Chức năng chính của HomeBloc:
// 1) Nhận các sự kiện yêu cầu load hoặc refresh màn Home (HomeLoadRequested,
//    HomeRefreshRequested).
// 2) Gọi usecase BuildHomeVM để gom toàn bộ dữ liệu cần cho UI:
//       - Continue Reading (lịch sử đọc local)
//       - Recommended (trending)
//       - Latest Updates (mới cập nhật)
// 3) Sau khi gom xong, đẩy dữ liệu vào HomeState cho UI render.
//
// Lưu ý quan trọng:
// - BuildHomeVM là nơi gom tất cả dữ liệu từ các module khác: discovery,
//   library_manga,... giúp HomeBloc chỉ còn nhiệm vụ điều phối, không xử lý logic.
// - HomeBloc vẫn tuân theo Clean Architecture: UI → Bloc → Usecases → Repo.
// - Hai event Load và Refresh đều dùng chung _onLoad() vì logic giống hệt nhau.
// -----------------------------------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'home_event.dart';
import 'home_state.dart';

import 'package:home/application/usecases/build_home_vm.dart';
import 'package:home/domain/entities/home_vm.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // ---------------------------------------------------------------------------
  // Biến private giữ instance của usecase BuildHomeVM
  // Usecase này sẽ lo toàn bộ xử lý để tạo ra 1 HomeVM chứa đủ data cho UI.
  // ---------------------------------------------------------------------------
  final BuildHomeVM _buildHomeVM;

  // ---------------------------------------------------------------------------
  // Constructor:
  // - Nhận BuildHomeVM từ dependency injection (GetIt).
  // - Khởi tạo state ban đầu = HomeState.initial().
  // - Đăng ký handler cho các event:
  //     + HomeLoadRequested → load dữ liệu lần đầu
  //     + HomeRefreshRequested → refresh dữ liệu
  // ---------------------------------------------------------------------------
  HomeBloc({
    required BuildHomeVM buildHomeVM,
  })  : _buildHomeVM = buildHomeVM,
        super(const HomeState.initial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onLoad);
  }

  // ---------------------------------------------------------------------------
  // _onLoad()
  //
  // Đây là hàm xử lý chính cho cả load và refresh.
  //
  // Quy trình:
  // 1. Emit state loading để UI show spinner.
  // 2. Gọi BuildHomeVM() -> gom dữ liệu từ nhiều nguồn:
  //      - getContinueReading()
  //      - getTrending()
  //      - getLatestUpdates()
  // 3. Nếu thành công: emit success + đẩy dữ liệu vào state.
  // 4. Nếu có lỗi: emit failure + ghi error vào state.errorMessage.
  //
  // Ưu điểm:
  // - Gọn, không chứa logic business trong Bloc.
  // - Thân thiện với test vì BuildHomeVM có thể mock dễ dàng.
  // ---------------------------------------------------------------------------
  Future<void> _onLoad(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // Gọi usecase gom toàn bộ dữ liệu Home vào HomeVM
      final HomeVM vm = await _buildHomeVM();

      // Thành công → cập nhật state đầy đủ
      emit(
        state.copyWith(
          status: HomeStatus.success,
          continueReading: vm.continueReading,
          recommended: vm.recommended,
          latestUpdates: vm.latestUpdates,
          errorMessage: null,
        ),
      );
    } catch (e) {
      // Nếu có lỗi → emit failure
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
