part of 'search_bloc.dart';

/// ======================================================================
/// STATE: SearchState
///
/// Vai trò:
///   - Đại diện toàn bộ trạng thái của màn hình Tìm kiếm.
///   - Được phát ra (emit) bởi SearchBloc để UI rebuild phù hợp.
///
/// Thành phần chính:
///   • status       : vòng đời tải dữ liệu (initial/loading/success/failure/loadingMore)
///   • query        : chuỗi người dùng đang tìm
///   • genre        : thể loại đang lọc (null = không lọc)
///   • items        : danh sách kết quả Manga hiện có
///   • hasMore      : còn trang tiếp theo để loadMore hay không
///   • offset       : đã tải bao nhiêu item (phục vụ phân trang)
///   • errorMessage : thông báo lỗi gần nhất (nếu có)
///
/// Quy ước:
///   - `initial()` dùng khi chưa có tương tác nào.
///   - Mọi thay đổi dùng `copyWith()` để giữ tính bất biến.
///   - `copyWith()` có cờ `setGenreNull` để phân biệt
///       + setGenreNull = true  → ép genre = null
///       + setGenreNull = false → giữ nguyên hoặc set bằng tham số `genre`
/// ======================================================================

enum SearchStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
}

class SearchState extends Equatable {
  /// Vòng đời trạng thái tải dữ liệu tìm kiếm
  final SearchStatus status;

  /// Chuỗi tìm kiếm hiện tại (có thể rỗng nếu chỉ lọc theo thể loại)
  final String query;

  /// Thể loại đang chọn; null = không lọc (All)
  final String? genre;

  /// Danh sách kết quả manga đã fetch về
  final List<Manga> items;

  /// Cờ cho biết còn dữ liệu để load thêm hay không
  final bool hasMore;

  /// Offset hiện tại, biểu thị đã tải bao nhiêu item
  final int offset;

  /// Thông báo lỗi gần nhất (hiển thị nhẹ nhàng trên UI nếu cần)
  final String? errorMessage;

  const SearchState({
    required this.status,
    required this.query,
    required this.genre,
    required this.items,
    required this.hasMore,
    required this.offset,
    required this.errorMessage,
  });

  /// Trạng thái khởi tạo: chưa có kết quả, chưa có query/genre.
  const SearchState.initial()
      : status = SearchStatus.initial,
        query = '',
        genre = null,
        items = const [],
        hasMore = false,
        offset = 0,
        errorMessage = null;

  /// Sao chép state với các thay đổi cần thiết.
  /// Lưu ý xử lý riêng cho `genre`:
  ///   - truyền `setGenreNull: true` để ép genre = null
  ///   - nếu không, `genre` sẽ giữ nguyên khi đối số `genre` là null
  SearchState copyWith({
    SearchStatus? status,
    String? query,
    String? genre, // <- nullable field, nhưng copyWith cần phân biệt "muốn set null" vs "giữ nguyên"
    bool setGenreNull = false,
    List<Manga>? items,
    bool? hasMore,
    int? offset,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      genre: setGenreNull ? null : (genre ?? this.genre),
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, query, genre, items, hasMore, offset, errorMessage];
}
