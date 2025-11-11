// lib/presentation/bloc/search_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/search_manga.dart';
import '../../domain/entities/manga.dart';

part 'search_event.dart';
part 'search_state.dart';

/// ======================================================================
/// BLoC: SearchBloc
///
/// Mục đích:
///   - Quản lý tìm kiếm manga theo `query` và/hoặc `genre`.
///   - Giữ danh sách kết quả, offset phân trang, cờ `hasMore`,
///     và trạng thái (loading / success / failure / loadingMore).
///
/// Luồng chính:
///   1) `SearchStarted(query, genre)`
///      - Reset state → loading
///      - Gọi usecase `SearchManga` trang đầu (offset=0, limit=pageSize)
///      - Emit success/failure tương ứng
///   2) `SearchLoadMore()`
///      - Bỏ qua nếu không còn trang / đang loadMore / không có tiêu chí tìm.
///      - Gọi tiếp `SearchManga` với offset hiện tại, nối thêm kết quả.
///
/// Quy ước:
///   - `pageSize = 20` cho UX mượt.
///   - `genre == null` nghĩa là không lọc theo thể loại (All).
///   - `query` có thể rỗng, cho phép lọc chỉ theo `genre`.
///
/// Lưu ý trong file này:
///   - Có **khối xử lý trùng lặp** trong `_onSearchStarted`: sau khi fetch và emit
///     một lần, code lại emit loading và gọi API lần nữa. Đây gần như chắc chắn
///     là dư thừa. Mình CHỈ GẮN NOTE, KHÔNG SỬA LOGIC theo yêu cầu của bạn.
/// ======================================================================
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchManga _searchManga;

  static const pageSize = 20; // kích thước trang mặc định cho phân trang

  SearchBloc({required SearchManga searchManga})
      : _searchManga = searchManga,
        super(const SearchState.initial()) {
    on<SearchStarted>(_onSearchStarted);
    on<SearchLoadMore>(_onSearchLoadMore);
  }

  /// ====================================================================
  /// Handler: SearchStarted
  ///
  /// Input:
  ///   - query: chuỗi tìm kiếm (có thể rỗng)
  ///   - genre: tên thể loại (nullable). null/empty → All.
  ///
  /// Hành vi:
  ///   - Đưa state về loading + reset paging.
  ///   - Gọi `_searchManga` trang đầu với `offset=0`.
  ///   - Emit success/failure.
  ///
  /// NOTE QUAN TRỌNG:
  ///   - Đoạn mã dưới hiện tại đang gọi API và emit KÉP (trùng logic)
  ///     theo đúng code bạn dán. Mình thêm comment đánh dấu
  ///     (// === DUPLICATE BLOCK START ===) để bạn dọn sau.
  /// ====================================================================
  Future<void> _onSearchStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    final q = event.query.trim();
    final g = event.genre?.trim();

    // Flag tham khảo: không được dùng ở dưới, có thể là ý định ban đầu
    // để quyết định có fetch hay không. Hiện vẫn giữ nguyên để không
    // thay đổi hành vi.
    final bool isEmptySearch = (q.isEmpty && (g == null || g.isEmpty));

    // === DUPLICATE BLOCK START (1/2) ==============================
    // Khối 1: emit loading + fetch + emit success/failure
    // (Khối tương tự sẽ lặp lại ngay bên dưới)
    // Luồng này đã đầy đủ cho SearchStarted.
    emit(SearchState(
      status: SearchStatus.loading,
      query: q,
      genre: (g != null && g.isNotEmpty) ? g : null,
      items: const [],
      hasMore: true,
      offset: 0,
      errorMessage: null,
    ));

    try {
      final list = await _searchManga(
        query: q,                         // rỗng cũng OK
        genre: (g != null && g.isNotEmpty) ? g : null, // null = All
        offset: 0,
        limit: pageSize,
      );

      emit(SearchState(
        status: SearchStatus.success,
        query: q,
        genre: (g != null && g.isNotEmpty) ? g : null,
        items: list,
        hasMore: list.length == pageSize,
        offset: list.length,
        errorMessage: null,
      ));
    } catch (e) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: q,
        genre: (g != null && g.isNotEmpty) ? g : null,
        items: const [],
        hasMore: false,
        offset: 0,
        errorMessage: e.toString(),
      ));
    }
    // === DUPLICATE BLOCK END (1/2) ================================


    // === DUPLICATE BLOCK START (2/2) ==============================
    // Khối 2: lặp lại y hệt logic khối 1 (emit loading → fetch → emit).
    // Giữ nguyên theo yêu cầu, nhưng highly recommended xóa khối lặp này.
    //
    // set state -> loading cho trang đầu
    emit(SearchState(
      status: SearchStatus.loading,
      query: q,
      genre: (g != null && g.isNotEmpty) ? g : null,
      items: const [],
      hasMore: true,
      offset: 0,
      errorMessage: null,
    ));

    try {
      final list = await _searchManga(
        query: q,
        genre: (g != null && g.isNotEmpty) ? g : null,
        offset: 0,
        limit: pageSize,
      );

      emit(SearchState(
        status: SearchStatus.success,
        query: q,
        genre: (g != null && g.isNotEmpty) ? g : null,
        items: list,
        hasMore: list.length == pageSize,
        offset: list.length,
        errorMessage: null,
      ));
    } catch (e) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: q,
        genre: (g != null && g.isNotEmpty) ? g : null,
        items: const [],
        hasMore: false,
        offset: 0,
        errorMessage: e.toString(),
      ));
    }
    // === DUPLICATE BLOCK END (2/2) ================================
  }

  /// ====================================================================
  /// Handler: SearchLoadMore
  ///
  /// Điều kiện chặn:
  ///   - `!state.hasMore`: đã hết dữ liệu.
  ///   - `state.status == loadingMore`: đang loadMore rồi.
  ///   - `state.query.isEmpty && (state.genre == null || empty)`:
  ///      không có tiêu chí tìm kiếm để tiếp tục phân trang.
  ///
  /// Hành vi:
  ///   - Emit `loadingMore`.
  ///   - Gọi `_searchManga` với offset hiện tại.
  ///   - Nối thêm kết quả, cập nhật `offset`/`hasMore`.
  ///   - Nếu lỗi ở loadMore: giữ data cũ, đặt `hasMore=false`, ném error nhẹ.
  /// ====================================================================
  Future<void> _onSearchLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    // Chặn spam loadMore khi:
    // - không còn trang tiếp theo
    // - đang loadMore sẵn rồi
    // - không có query và cũng không có genre => nothing to continue
    if (!state.hasMore ||
        state.status == SearchStatus.loadingMore ||
        (state.query.isEmpty && (state.genre == null || state.genre!.isEmpty))) {
      return;
    }

    emit(state.copyWith(status: SearchStatus.loadingMore));

    try {
      final more = await _searchManga(
        query: state.query,
        genre: state.genre,
        offset: state.offset,
        limit: pageSize,
      );

      emit(state.copyWith(
        status: SearchStatus.success,
        items: [...state.items, ...more],
        hasMore: more.length == pageSize,
        offset: state.offset + more.length,
      ));
    } catch (e) {
      // Nếu loadMore fail thì vẫn giữ data cũ,
      // chỉ đánh dấu ko load thêm nữa & báo lỗi nhẹ
      emit(state.copyWith(
        status: SearchStatus.success,
        hasMore: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
