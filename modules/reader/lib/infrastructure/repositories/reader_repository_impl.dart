// lib/infrastructure/repositories/reader_repository_impl.dart
import 'package:reader/domain/entities/page_image.dart';
import 'package:reader/domain/repositories/reader_repository.dart';

import '../datasources/reader_remote_ds.dart';
import '../../domain/value_objects/at_home_url.dart';

/// ReaderRepositoryImpl:
/// map JSON từ at-home server -> List<PageImage>
/// prefetchPages/reportImageError hiện tại làm nhẹ nhàng.
class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource _remote;

  ReaderRepositoryImpl(this._remote);

  @override
  Future<List<PageImage>> getChapterPages({
    required String chapterId,
  }) async {
    final raw = await _remote.fetchChapterPagesRaw(
      chapterId: chapterId,
    );

    final baseUrl = raw['baseUrl']?.toString() ?? '';
    final ch = (raw['chapter'] as Map<String, dynamic>? ?? {});
    final hash = ch['hash']?.toString() ?? '';
    final dataList = (ch['data'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final atHome = AtHomeUrl(baseUrl: baseUrl, hash: hash);

    final pages = <PageImage>[];
    for (var i = 0; i < dataList.length; i++) {
      final fileName = dataList[i];
      final url = atHome.buildPageUrl(fileName);
      pages.add(
        PageImage(
          index: i,
          imageUrl: url,
        ),
      );
    }

    return pages;
  }

  @override
  Future<void> prefetchPages({
    required List<PageImage> pages,
  }) async {
    // MVP: không làm gì phức tạp
    // Có thể trigger cache warm-up bằng cách HEAD request/cache disk sau này.
    return;
  }

  @override
  Future<void> reportImageError({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  }) async {
    // MVP: log thôi. Trong production có thể gửi analytics.
    // print để debug (không crash UI).
    // ignore: avoid_print
    print(
        "[ReaderRepositoryImpl] Image error chapter=$chapterId page=$pageIndex url=$imageUrl");
    return;
  }
}
