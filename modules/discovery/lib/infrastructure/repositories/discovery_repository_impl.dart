import 'package:discovery/domain/value_objects/feed_cursor.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:discovery/domain/repositories/discovery_repository.dart';

import '../datasources/discovery_remote_ds.dart';

/// DiscoveryRepositoryImpl
/// chuyển raw json từ RemoteDataSource thành FeedItem sạch
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource _remote;
  DiscoveryRepositoryImpl(this._remote);

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

  /// parse 1 object manga từ MangaDex -> FeedItem
  FeedItem _mapMangaJsonToFeedItem(Map<String, dynamic> m) {
    final String id = (m['id'] ?? '').toString();

    final attr = (m['attributes'] as Map<String, dynamic>? ?? {});
    final titleMap = (attr['title'] as Map<String, dynamic>? ?? {});
    final altTitles = (attr['altTitles'] as List<dynamic>? ?? []);

    // lấy title ưu tiên:
    // 1. title['en']
    // 2. altTitles[0]['en'] ...
    // 3. bất kỳ value string đầu tiên
    String _pickTitle() {
      if (titleMap['en'] is String && (titleMap['en'] as String).isNotEmpty) {
        return titleMap['en'] as String;
      }
      for (final alt in altTitles) {
        if (alt is Map<String, dynamic>) {
          if (alt['en'] is String && (alt['en'] as String).isNotEmpty) {
            return alt['en'] as String;
          }
          // fallback first value
          if (alt.isNotEmpty) {
            final firstVal = alt.values.first;
            if (firstVal is String && firstVal.isNotEmpty) {
              return firstVal;
            }
          }
        }
      }
      // fallback any value từ titleMap
      if (titleMap.isNotEmpty) {
        final firstVal = titleMap.values.first;
        if (firstVal is String && firstVal.isNotEmpty) {
          return firstVal;
        }
      }
      return 'Untitled';
    }

    final status = (attr['status'] ?? 'unknown').toString();

    // lastChapterOrUpdate -> show dưới status (ví dụ "Ch.123")
    String? lastChapterOrUpdate;
    if (attr['lastChapter'] != null &&
        attr['lastChapter'].toString().trim().isNotEmpty) {
      lastChapterOrUpdate = "Ch.${attr['lastChapter']}";
    } else if (attr['updatedAt'] != null) {
      // quá lười format time tương đối => show yyyy-mm-dd
      final raw = attr['updatedAt'].toString();
      lastChapterOrUpdate = raw;
    }

    // tags
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

    // cover art build url:
    // https://uploads.mangadex.org/covers/{mangaId}/{fileName}.256.jpg
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
