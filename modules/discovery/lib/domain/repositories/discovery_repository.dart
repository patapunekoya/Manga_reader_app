// lib/domain/repositories/discovery_repository.dart

import '../entities/feed_item.dart';
import '../value_objects/feed_cursor.dart';

/// DiscoveryRepository:
/// Nơi cung cấp dữ liệu cho trang Khám phá (Home).
///
/// Tầng Application chỉ nói chuyện qua abstract repository.
/// Tầng Infrastructure (Dio / HTTP) sẽ implement các phương thức này.
///
/// Lý do tách:
/// - Discovery có payload nhẹ hơn Catalog (không cần mô tả chi tiết truyện).
/// - Giảm tải cho usecase Search / MangaDetail.
/// - Giữ Home feed chạy nhanh, ít data.
abstract class DiscoveryRepository {
  /// Lấy danh sách trending (phổ biến).
  /// Hỗ trợ phân trang qua FeedCursor(offset + limit).
  Future<List<FeedItem>> getTrending({
    required FeedCursor cursor,
  });

  /// Lấy danh sách manga vừa cập nhật gần đây.
  /// Cũng hỗ trợ phân trang.
  Future<List<FeedItem>> getLatestUpdates({
    required FeedCursor cursor,
  });
}
