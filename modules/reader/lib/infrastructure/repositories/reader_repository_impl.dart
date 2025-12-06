import 'package:reader/domain/entities/page_image.dart';
import 'package:reader/domain/repositories/reader_repository.dart';

import '../datasources/reader_remote_ds.dart';
import '../../domain/value_objects/at_home_url.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource _remote;

  ReaderRepositoryImpl(this._remote);

  @override
  Future<List<PageImage>> getChapterPages({
    required String chapterId,
  }) async {
    // 1. Gọi API lấy raw JSON
    final raw = await _remote.fetchChapterPagesRaw(
      chapterId: chapterId,
    );

    // 2. Lấy baseUrl từ response (QUAN TRỌNG: không hardcode)
    final baseUrl = raw['baseUrl']?.toString() ?? '';
    final ch = (raw['chapter'] as Map<String, dynamic>? ?? {});

    // 3. Hash & Data
    final hash = ch['hash']?.toString() ?? '';
    final dataList = (ch['data'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // 4. Tạo AtHomeUrl
    final atHome = AtHomeUrl(baseUrl: baseUrl, hash: hash);

    // 5. Map thành PageImage
    final pages = <PageImage>[];
    for (var i = 0; i < dataList.length; i++) {
      final fileName = dataList[i];
      // Logic build URL nằm trong Value Object
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
  Future<void> prefetchPages({required List<PageImage> pages}) async {
    // MVP: No-op
    return;
  }

  @override
  Future<void> reportImageError({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  }) async {
    // MVP: Log error
    // ignore: avoid_print
    print("[ReaderRepo] Error loading image: $imageUrl (chap: $chapterId, page: $pageIndex)");
    return;
  }
}