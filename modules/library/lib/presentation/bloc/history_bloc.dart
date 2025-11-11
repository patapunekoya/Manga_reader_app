import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_continue_reading.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/library_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

/// ============================================================================
/// HistoryBloc
/// ----------------------------------------------------------------------------
/// Mục đích:
/// - Quản lý lịch sử đọc (Continue Reading) theo CHAPTER gần nhất của mỗi manga.
/// - Cho phép:
///   1) Load lịch sử đọc từ local (Hive) thông qua usecase GetContinueReading.
///   2) Xóa sạch toàn bộ lịch sử đọc (clearAllProgress) qua LibraryRepository.
///
/// Luồng dữ liệu tổng quát:
/// - UI dispatch:
///     • HistoryLoadRequested()      -> load danh sách lịch sử đọc
///     • HistoryClearAllRequested()  -> xóa sạch lịch sử rồi load lại
/// - Bloc phản hồi:
///     • status: loading/success/failure
///     • history: List<ReadingProgress> đã sort ở repo (mới nhất trước)
///
/// Ghi chú triển khai:
/// - GetContinueReading: usecase chỉ đọc dữ liệu từ LibraryRepository (local).
/// - LibraryRepository.clearAllProgress(): xóa all progress theo key mangaId.
/// - State giữ errorMessage để UI show thông báo khi xảy ra lỗi.
/// - Dùng Equatable để tối ưu rebuild UI.
/// ============================================================================
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  /// Usecase đọc danh sách progress (đã được map thành ReadingProgress).
  final GetContinueReading _getContinueReading;

  /// Repository để thực hiện thao tác ghi/xóa (ở đây dùng clearAllProgress()).
  final LibraryRepository _repo;

  /// ----------------------------------------------------------------------------
  /// Khởi tạo:
  /// - Gắn handler cho 2 event chính:
  ///   • HistoryLoadRequested      -> _onLoadRequested
  ///   • HistoryClearAllRequested  -> _onClearAllRequested
  /// ----------------------------------------------------------------------------
  HistoryBloc({
    required GetContinueReading getContinueReading,
    required LibraryRepository repo,
  })  : _getContinueReading = getContinueReading,
        _repo = repo,
        super(const HistoryState.initial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryClearAllRequested>(_onClearAllRequested); // NEW
  }

  /// ----------------------------------------------------------------------------
  /// _onLoadRequested:
  /// - Đặt trạng thái loading.
  /// - Gọi usecase _getContinueReading() để lấy danh sách ReadingProgress.
  /// - Thành công: status = success, history = list.
  /// - Lỗi:        status = failure, errorMessage = e.toString()
  /// ----------------------------------------------------------------------------
  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final list = await _getContinueReading();
      emit(state.copyWith(status: HistoryStatus.success, history: list));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }

  /// ----------------------------------------------------------------------------
  /// _onClearAllRequested:
  /// - Gọi _repo.clearAllProgress() để xóa sạch lịch sử đọc trong local storage.
  /// - Sau khi xóa, load lại danh sách để đồng bộ UI.
  /// - Thành công: status = success, history = list (thường rỗng).
  /// - Lỗi:        status = failure, errorMessage = e.toString()
  ///
  /// Lưu ý UI/UX:
  /// - Hành động này thường nên có confirm ở UI trước khi dispatch event.
  /// - Sau khi xóa, state trả về danh sách rỗng để UI ẩn strip/section tương ứng.
  /// ----------------------------------------------------------------------------
  Future<void> _onClearAllRequested(
    HistoryClearAllRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repo.clearAllProgress();
      final list = await _getContinueReading();
      emit(state.copyWith(status: HistoryStatus.success, history: list));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }
}
