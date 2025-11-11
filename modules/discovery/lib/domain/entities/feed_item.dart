import 'package:equatable/equatable.dart';

/// FeedItem: mô hình dữ liệu rút gọn cho màn Home / Trending / Latest Updates.
/// 
/// Đây là entity “nhẹ” dùng trong Discovery module.
/// Không chứa logic hay phụ thuộc tầng dưới.
/// 
/// Dùng để:
/// - Render card manga trong trang chủ.
/// - Hiển thị trending / latest updates.
/// - Navigate sang MangaDetail bằng id.
///
/// Các trường đều an toàn, không ép buộc UI phải biết JSON của MangaDex.
class FeedItem extends Equatable {
  /// ID manga (string thuần từ MangaDex)
  final String id;

  /// Tiêu đề hiển thị
  final String title;

  /// Trạng thái: ongoing / completed / hiatus / dropped
  final String status;

  /// Link cover art (có thể null nếu không có)
  final String? coverImageUrl;

  /// Subtext: ví dụ "Ch.123" hoặc datetime update
  final String? lastChapterOrUpdate;

  /// Danh sách 1–2 tag nổi bật
  final List<String> tags;

  const FeedItem({
    required this.id,
    required this.title,
    required this.status,
    required this.coverImageUrl,
    required this.lastChapterOrUpdate,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        coverImageUrl,
        lastChapterOrUpdate,
        tags,
      ];
}
