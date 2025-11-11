// lib/infrastructure/repositories/reader_repository_impl.dart

import 'package:reader/domain/entities/page_image.dart';
import 'package:reader/domain/repositories/reader_repository.dart';

import '../datasources/reader_remote_ds.dart';
import '../../domain/value_objects/at_home_url.dart';

/// ReaderRepositoryImpl
/// ---------------------------------------------------------------------------
/// Đây là tầng Infrastructure – nơi nói chuyện trực tiếp với DataSource (API).
///
/// Nhiệm vụ:
/// 1. Gọi ReaderRemoteDataSource để lấy raw JSON từ MangaDex at-home server.
/// 2. Parse JSON -> chuyển thành danh sách PageImage (index + imageUrl).
/// 3. Gửi log lỗi ảnh (reportImageError) nếu cần.
/// 4. Prefetch (hiện tại để trống – MVP).
///
/// Dạng JSON từ MangaDex /at-home/server/{chapterId}:
/// {
///   "baseUrl": "https://uploads.mangadex.org",
///   "chapter": {
///     "hash": "df12abced123...",
///     "data": ["01.jpg", "02.jpg", ...],       // full-quality
///     "dataSaver": ["01-s.jpg", "02-s.jpg"]   // low-quality (tuỳ chọn)
///   }
/// }
///
/// Công thức build URL:
///   full:       {baseUrl}/data/{hash}/{filename}
///   data-saver: {baseUrl}/data-saver/{hash}/{filename}
///
/// File này chọn full-quality mặc định.
/// ---------------------------------------------------------------------------

class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource _remote;

  /// Inject datasource
  ReaderRepositoryImpl(this._remote);

  @override
  Future<List<PageImage>> getChapterPages({
    required String chapterId,
  }) async {
    // 1. Gọi API MangaDex at-home server để lấy raw JSON
    final raw = await _remote.fetchChapterPagesRaw(
      chapterId: chapterId,
    );

    // 2. Tách baseUrl và phần "chapter"
    final baseUrl = raw['baseUrl']?.toString() ?? '';
    final ch = (raw['chapter'] as Map<String, dynamic>? ?? {});

    // 3. Lấy hash của chapter
    final hash = ch['hash']?.toString() ?? '';

    // 4. Lấy danh sách file ảnh full quality
    final dataList = (ch['data'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // 5. Tạo AtHomeUrl để build link ảnh chuẩn MangaDex
    final atHome = AtHomeUrl(baseUrl: baseUrl, hash: hash);

    // 6. Map danh sách fileName -> PageImage(index + url)
    final pages = <PageImage>[];
    for (var i = 0; i < dataList.length; i++) {
      final fileName = dataList[i];

      // Build URL đầy đủ
      final url = atHome.buildPageUrl(fileName);

      pages.add(
        PageImage(
          index: i,        // số thứ tự trang
          imageUrl: url,   // đường dẫn ảnh final
        ),
      );
    }

    // 7. Trả về danh sách PageImage cho ReaderBloc -> UI Reader
    return pages;
  }

  @override
  Future<void> prefetchPages({
    required List<PageImage> pages,
  }) async {
    // MVP: chưa implement prefetch để tránh phức tạp.
    // Tương lai có thể preload ảnh vào cache.
    return;
  }

  @override
  Future<void> reportImageError({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  }) async {
    // MVP: chỉ log ra console để dev thấy.
    // Production: có thể gửi lên server để theo dõi lỗi.
    // ignore: avoid_print
    print(
      "[ReaderRepositoryImpl] Image error chapter=$chapterId page=$pageIndex url=$imageUrl",
    );
    return;
  }
}
