// lib/application/usecases/get_latest_updates.dart

import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/value_objects/feed_cursor.dart';

/// Usecase GetLatestUpdates:
/// Lấy manga mới cập nhật gần đây.
class GetLatestUpdates {
  final DiscoveryRepository _repo;

  const GetLatestUpdates(this._repo);

  Future<List<FeedItem>> call({required FeedCursor cursor}) {
    return _repo.getLatestUpdates(cursor: cursor);
  }
}
