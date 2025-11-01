// lib/domain/repositories/discovery_repository.dart

import '../entities/feed_item.dart';
import '../value_objects/feed_cursor.dart';

/// DiscoveryRepository là abstraction của nguồn dữ liệu "khám phá":
/// trending manga, latest updates,...
///
/// Tầng application (usecases) chỉ biết interface này.
/// Tầng infrastructure sẽ implement nó dùng Dio.
abstract class DiscoveryRepository {
  /// Lấy danh sách manga trending / phổ biến.
  /// Có hỗ trợ phân trang qua FeedCursor.
  Future<List<FeedItem>> getTrending({
    required FeedCursor cursor,
  });

  /// Lấy danh sách manga cập nhật mới nhất.
  /// Cũng dùng phân trang.
  Future<List<FeedItem>> getLatestUpdates({
    required FeedCursor cursor,
  });
}
