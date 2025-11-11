import 'package:discovery/domain/value_objects/feed_cursor.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:discovery/domain/repositories/discovery_repository.dart';

import '../datasources/discovery_remote_ds.dart';

/// ---------------------------------------------------------------------------
/// DiscoveryRepositoryImpl
/// ---------------------------------------------------------------------------
/// Vai trò:
/// - Tầng Repository của module Discovery: nhận RAW JSON từ RemoteDataSource,
///   map sang Entity sạch `FeedItem` cho tầng application/UI.
/// - Ẩn chi tiết API (endpoint, query params) khỏi phần còn lại của app.
///
/// Lý do tách lớp:
/// - DataSource: chỉ gọi HTTP và trả raw Map/List.
/// - Repository: chịu trách nhiệm convert dữ liệu raw -> domain entity.
/// - Dễ test: mock DataSource để test mapper, phân trang, xử lý lỗi.
///
/// Hợp đồng với Interface:
/// - Implements DiscoveryRepository: getTrending(), getLatestUpdates()
///   đều dùng FeedCursor(offset, limit) để phân trang.
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  /// Nguồn dữ liệu từ xa (HTTP client gói trong DataSource).
  final DiscoveryRemoteDataSource _remote;

  /// Inject qua DI (GetIt) ở bootstrap.
  DiscoveryRepositoryImpl(this._remote);

  // -------------------------------------------------------------------------
  // getTrending
  // -------------------------------------------------------------------------
  /// Nhiệm vụ:
  /// - Gọi DataSource.fetchTrending(offset, limit)
  /// - Map từng item JSON sang FeedItem qua `_mapMangaJsonToFeedItem`.
  ///
  /// Không xử lý lỗi chi tiết ở đây:
  /// - Nếu HTTP fail, DataSource có thể ném lỗi; tầng trên (usecase/bloc)
  ///   sẽ quyết định hiển thị thông báo hay retry.
  @override
  Future<List<FeedItem>> getTrending({
    required FeedCursor cursor,
  }) async {
    final rawList = await _remote.fetchTrending(
      offset: cursor.offset,
      limit: cursor.limit,
    );
    return rawList.map(_mapMangaJsonToFeedItem).toList();
  }

  // -------------------------------------------------------------------------
  // getLatestUpdates
  // -------------------------------------------------------------------------
  /// Nhiệm vụ:
  /// - Gọi DataSource.fetchLatestUpdates(offset, limit)
  /// - Map sang FeedItem tương tự trending.
  @override
  Future<List<FeedItem>> getLatestUpdates({
    required FeedCursor cursor,
  }) async {
    final rawList = await _remote.fetchLatestUpdates(
      offset: cursor.offset,
      limit: cursor.limit,
    );
    return rawList.map(_mapMangaJsonToFeedItem).toList();
  }

  // -------------------------------------------------------------------------
  // _mapMangaJsonToFeedItem
  // -------------------------------------------------------------------------
  /// Chuyển 1 object manga (JSON từ MangaDex) thành FeedItem:
  /// - Ưu tiên title tiếng Anh; nếu không có thì lấy altTitles; cuối cùng
  ///   rơi về bất kỳ string đầu tiên có trong map.
  /// - status: lấy từ attributes.status.
  /// - lastChapterOrUpdate: nếu có lastChapter -> "Ch.{n}", ngược lại dùng
  ///   updatedAt (ISO string) làm chuỗi mô tả phụ.
  /// - tags: lấy tối đa các tên tag (ưu tiên 'en', fallback bất kỳ value).
  /// - coverImageUrl: đọc từ relationships.type == 'cover_art' để build URL
  ///   theo format uploads.mangadex.org/covers/{mangaId}/{fileName}.256.jpg
  ///
  /// Ghi chú an toàn:
  /// - Tất cả field đọc dạng defensive (nullable, kiểu động), tránh crash khi
  ///   API đổi schema nhỏ.
  FeedItem _mapMangaJsonToFeedItem(Map<String, dynamic> m) {
    // id manga
    final String id = (m['id'] ?? '').toString();

    // attributes & tiêu đề
    final attr = (m['attributes'] as Map<String, dynamic>? ?? {});
    final titleMap = (attr['title'] as Map<String, dynamic>? ?? {});
    final altTitles = (attr['altTitles'] as List<dynamic>? ?? []);

    // chọn title theo thứ tự ưu tiên
    String _pickTitle() {
      // 1) title['en']
      if (titleMap['en'] is String && (titleMap['en'] as String).isNotEmpty) {
        return titleMap['en'] as String;
      }
      // 2) altTitles[*]['en'] hoặc value đầu tiên
      for (final alt in altTitles) {
        if (alt is Map<String, dynamic>) {
          if (alt['en'] is String && (alt['en'] as String).isNotEmpty) {
            return alt['en'] as String;
          }
          if (alt.isNotEmpty) {
            final firstVal = alt.values.first;
            if (firstVal is String && firstVal.isNotEmpty) {
              return firstVal;
            }
          }
        }
      }
      // 3) bất kỳ value đầu tiên trong titleMap
      if (titleMap.isNotEmpty) {
        final firstVal = titleMap.values.first;
        if (firstVal is String && firstVal.isNotEmpty) {
          return firstVal;
        }
      }
      // Fallback cuối
      return 'Untitled';
    }

    // trạng thái (ongoing/completed/...)
    final status = (attr['status'] ?? 'unknown').toString();

    // lastChapterOrUpdate: ưu tiên lastChapter, nếu không có dùng updatedAt raw
    String? lastChapterOrUpdate;
    if (attr['lastChapter'] != null &&
        attr['lastChapter'].toString().trim().isNotEmpty) {
      lastChapterOrUpdate = "Ch.${attr['lastChapter']}";
    } else if (attr['updatedAt'] != null) {
      // Có thể format đẹp hơn ở UI; repo giữ nguyên để UI tự quyết
      final raw = attr['updatedAt'].toString();
      lastChapterOrUpdate = raw;
    }

    // tags: rút tên tag ưu tiên name['en'], fallback value đầu
    final List<String> tags = [];
    if (attr['tags'] is List) {
      for (final t in (attr['tags'] as List)) {
        if (t is Map<String, dynamic>) {
          final tAttr = (t['attributes'] as Map<String, dynamic>? ?? {});
          final nameMap = (tAttr['name'] as Map<String, dynamic>? ?? {});
          if (nameMap['en'] is String && (nameMap['en'] as String).isNotEmpty) {
            tags.add(nameMap['en'] as String);
          } else if (nameMap.isNotEmpty) {
            final firstVal = nameMap.values.first;
            if (firstVal is String && firstVal.isNotEmpty) {
              tags.add(firstVal);
            }
          }
        }
      }
    }

    // cover: đọc từ relationships -> cover_art -> attributes.fileName
    // build url .256.jpg để UI hiển thị nhanh, đủ nét cho grid/list
    String? coverUrl;
    if (m['relationships'] is List) {
      for (final rel in (m['relationships'] as List)) {
        if (rel is Map<String, dynamic>) {
          if (rel['type'] == 'cover_art') {
            final relAttr =
                (rel['attributes'] as Map<String, dynamic>? ?? {});
            final fileName = relAttr['fileName']?.toString();
            if (fileName != null && fileName.isNotEmpty) {
              coverUrl =
                  "https://uploads.mangadex.org/covers/$id/$fileName.256.jpg";
              break;
            }
          }
        }
      }
    }

    // Kết quả cuối: entity sạch cho UI
    return FeedItem(
      id: id,
      title: _pickTitle(),
      coverImageUrl: coverUrl,
      status: status,
      lastChapterOrUpdate: lastChapterOrUpdate,
      tags: tags,
    );
  }
}
