import 'package:equatable/equatable.dart';

/// FeedCursor: Value Object dùng cho phân trang Trending / Latest.
/// MangaDex sử dụng kiểu offset + limit.
///
/// offset: bắt đầu từ item thứ mấy (0, 20, 40...)
/// limit : số lượng item trả về mỗi page
///
/// Lưu ý:
/// KHÔNG được duplicate class này ở thư mục khác.
/// Mọi nơi trong Discovery (repository, impl, usecases, bloc)
/// phải import đúng VO này, nếu không sẽ lỗi so sánh Equatable
/// và state không update.
class FeedCursor extends Equatable {
  final int offset;
  final int limit;

  const FeedCursor({
    required this.offset,
    required this.limit,
  });

  /// Tạo con trỏ trang kế tiếp.
  FeedCursor nextPage() {
    return FeedCursor(
      offset: offset + limit,
      limit: limit,
    );
  }

  @override
  List<Object?> get props => [offset, limit];
}
