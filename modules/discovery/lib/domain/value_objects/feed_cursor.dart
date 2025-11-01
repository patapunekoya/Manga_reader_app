import 'package:equatable/equatable.dart';

/// FeedCursor: Value Object cho phân trang feed Trending / Latest.
///
/// MangaDex dùng offset + limit thay vì "cursor token".
/// - offset: bắt đầu từ item thứ mấy (0, 10, 20, ...)
/// - limit: lấy bao nhiêu item / page (10, 20, ...)
///
/// Vì nó là VO (value object), mình cho vào `domain/value_objects/`
/// chứ không bỏ chung với entities.
///
/// Lưu ý QUAN TRỌNG:
/// TẤT CẢ nơi nào dùng FeedCursor (DiscoveryRepository,
/// DiscoveryRepositoryImpl, GetTrending, GetLatestUpdates, HomeBloc)
/// PHẢI import đúng file này.
/// Nếu bạn copy class này sang chỗ khác (ví dụ /entities/) sẽ tạo ra 2 kiểu
/// khác nhau -> override bị lỗi như bạn đang gặp.
class FeedCursor extends Equatable {
  final int offset;
  final int limit;

  const FeedCursor({
    required this.offset,
    required this.limit,
  });

  /// Tạo con trỏ next page.
  /// Ví dụ: FeedCursor(offset: 0, limit: 10).nextPage()
  ///  => FeedCursor(offset: 10, limit: 10)
  FeedCursor nextPage() {
    return FeedCursor(
      offset: offset + limit,
      limit: limit,
    );
  }

  @override
  List<Object?> get props => [offset, limit];
}
