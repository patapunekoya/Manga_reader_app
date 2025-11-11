// lib/application/usecases/get_latest_updates.dart

import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/value_objects/feed_cursor.dart';

/// UseCase: GetLatestUpdates
///
/// Ý nghĩa:
/// - Đây là tầng Application.
/// - Chịu trách nhiệm thực thi một hành động kinh doanh: 
///     "Lấy danh sách manga cập nhật mới nhất".
///
/// - Nhận input là FeedCursor (offset, limit hoặc nextCursor tuỳ backend).
/// - Trả về danh sách FeedItem (đã là entity sạch).
///
/// - Không chứa logic API.
/// - Không chứa parsing JSON.
/// - Tất cả qua Repository interface.

class GetLatestUpdates {
  final DiscoveryRepository _repo;

  const GetLatestUpdates(this._repo);

  Future<List<FeedItem>> call({required FeedCursor cursor}) {
    // UseCase chỉ forward param xuống repository
    return _repo.getLatestUpdates(cursor: cursor);
  }
}
