// lib/application/usecases/get_trending.dart

import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/value_objects/feed_cursor.dart';

/// Usecase GetTrending:
/// Trả về danh sách FeedItem kiểu "phổ biến / trending".
class GetTrending {
  final DiscoveryRepository _repo;

  const GetTrending(this._repo);

  /// Thực thi usecase.
  /// cursor: FeedCursor(offset, limit) để phân trang.
  Future<List<FeedItem>> call({required FeedCursor cursor}) {
    return _repo.getTrending(cursor: cursor);
  }
}
