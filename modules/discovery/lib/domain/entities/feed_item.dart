import 'package:equatable/equatable.dart';

/// FeedItem: item truyện rút gọn để show ở home/trending
class FeedItem extends Equatable {
  /// manga id (dùng để navigate sang MangaDetail hoặc Reader)
  final String id;

  /// tiêu đề hiển thị
  final String title;

  /// trạng thái truyện: ongoing, completed, dropped...
  final String status;

  /// cover art url (có thể null nếu MangaDex không trả cover)
  final String? coverImageUrl;

  /// dòng phụ: vd "Ch.123", hoặc "2025-11-01T02:30:00"
  final String? lastChapterOrUpdate;

  /// 1-2 tag (action, romance, etc.)
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
