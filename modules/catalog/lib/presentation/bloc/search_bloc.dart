// lib/presentation/bloc/search_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/search_manga.dart';
import '../../domain/entities/manga.dart';

part 'search_event.dart';
part 'search_state.dart';

/// SearchBloc:
/// - giữ current query + current genre
/// - giữ danh sách kết quả hiện tại
/// - phân trang offset
/// - trạng thái loading thêm / hết data
///
/// Flow:
/// 1. user gõ query hoặc đổi genre -> SearchStarted(query: ..., genre: ...)
///    -> reset state, fetch trang đầu (offset=0)
/// 2. scroll gần cuối -> SearchLoadMore()
///    -> fetch offset += limit (giữ nguyên query + genre hiện tại)
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchManga _searchManga;

  static const pageSize = 20;

  SearchBloc({required SearchManga searchManga})
      : _searchManga = searchManga,
        super(const SearchState.initial()) {
    on<SearchStarted>(_onSearchStarted);
    on<SearchLoadMore>(_onSearchLoadMore);
  }

  Future<void> _onSearchStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    final q = event.query.trim();
    final g = event.genre?.trim();

    // nếu cả query rỗng và genre rỗng => quay về initial
    final bool isEmptySearch = (q.isEmpty && (g == null || g.isEmpty));
    if (isEmptySearch) {
      emit(const SearchState.initial());
      return;
    }

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
  }

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
