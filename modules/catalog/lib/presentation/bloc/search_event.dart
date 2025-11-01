part of 'search_bloc.dart';

@immutable
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

// BỔ SUNG: genre (nullable)
// - query: text user gõ
// - genre: thể loại đang chọn (null hoặc "Action"...)
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

// Load thêm trang tiếp theo dựa trên state hiện tại
class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}
