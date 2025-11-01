part of 'search_bloc.dart';

enum SearchStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
}

class SearchState extends Equatable {
  final SearchStatus status;

  // text user đang search
  final String query;

  // thể loại hiện tại (null = không lọc)
  final String? genre;

  // danh sách kết quả hiện có
  final List<Manga> items;

  // còn trang tiếp theo không
  final bool hasMore;

  // offset hiện tại (đã load bao nhiêu)
  final int offset;

  // lỗi gần nhất (nếu có)
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

  const SearchState.initial()
      : status = SearchStatus.initial,
        query = '',
        genre = null,
        items = const [],
        hasMore = false,
        offset = 0,
        errorMessage = null;

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
