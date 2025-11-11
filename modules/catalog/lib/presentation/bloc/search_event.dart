part of 'search_bloc.dart';

/// ======================================================================
/// SEARCH EVENTS
///
/// Đây là tập hợp các Event mà SearchBloc có thể nhận.
/// UI sẽ dispatch các Event này khi người dùng tương tác:
///   - Khi gõ vào ô tìm kiếm
///   - Khi chọn thể loại (genre)
///   - Khi scroll gần cuối danh sách (loadMore)
///
/// Tất cả Event đều extends Equatable để đảm bảo so sánh tối ưu,
/// tránh rebuild UI không cần thiết.
///
/// ======================================================================
@immutable
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// ======================================================================
/// Event: SearchStarted
///
/// Khi nào được dispatch?
///   - Khi user bắt đầu gõ search.
///   - Khi user chọn một thể loại từ filter.
///   - Khi UI muốn reset và chạy trang đầu.
///
/// Ý nghĩa params:
///   • query: chuỗi tìm kiếm (có thể rỗng → "Tìm theo thể loại").
///   • genre: tên thể loại (nullable).
///       - null → không lọc theo genre (All)
///       - "action" → lọc theo một thể loại cụ thể
///
/// Hành vi trong Bloc:
///   - Reset state → loading.
///   - Gọi SearchManga(offset=0).
///   - Lưu query + genre vào state để loadMore tiếp.
///
/// ======================================================================
class SearchStarted extends SearchEvent {
  final String query;
  final String? genre;

  const SearchStarted({
    required this.query,
    this.genre,
  });

  @override
  List<Object?> get props => [query, genre];
}

/// ======================================================================
/// Event: SearchLoadMore
///
/// Khi nào được dispatch?
///   - Khi ListView/GridView scroll tới gần cuối.
///   - Khi SearchBloc có `hasMore=true`.
///
/// Hành vi trong Bloc:
///   - Gọi SearchManga(offset = state.offset).
///   - Append kết quả vào cuối danh sách cũ.
///   - Cập nhật offset + hasMore.
///
/// Lưu ý:
///   - Bloc sẽ tự chặn event này nếu đang loadingMore
///     hoặc không có tiêu chí tìm kiếm hợp lệ.
///
/// ======================================================================
class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}
