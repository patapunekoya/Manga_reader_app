// lib/application/usecases/get_trending.dart

import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/value_objects/feed_cursor.dart';

/// UseCase: GetTrending
///
/// Trách nhiệm:
/// - Cung cấp hành động “lấy danh sách manga đang thịnh hành / trending”.
/// - Hoạt động ở tầng Application (không liên quan UI, không parse JSON).
/// - Chỉ gọi repository interface để lấy dữ liệu dạng entity sạch.
///
/// Input:
/// - FeedCursor (offset/limit) để phân trang.
///
/// Output:
/// - List<FeedItem> (entity ở tầng Domain).

class GetTrending {
  final DiscoveryRepository _repo;

  const GetTrending(this._repo);

  Future<List<FeedItem>> call({required FeedCursor cursor}) {
    // Forward xuống repository. Không nhét logic dơ vào đây.
    return _repo.getTrending(cursor: cursor);
  }
}
