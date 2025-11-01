// home/application/usecases/build_home_vm.dart

import 'package:home/domain/entities/home_vm.dart';

// lịch sử đọc (local)
import 'package:library_manga/application/usecases/get_continue_reading.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';

// trending & latest from discovery
import 'package:discovery/application/usecases/get_trending.dart';
import 'package:discovery/application/usecases/get_latest_updates.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:discovery/domain/value_objects/feed_cursor.dart';

/// BuildHomeVM:
/// Gom dữ liệu cho màn Home:
/// - continueReading (đọc dở)
/// - recommended (trending -> dùng cho carousel)
/// - latestUpdates (manga mới cập nhật)
class BuildHomeVM {
  final GetContinueReading _getContinueReading;
  final GetTrending _getTrending;
  final GetLatestUpdates _getLatestUpdates;

  const BuildHomeVM(
    this._getContinueReading,
    this._getTrending,
    this._getLatestUpdates,
  );

  Future<HomeVM> call() async {
    // 1. lịch sử đọc local
    final List<ReadingProgress> progressList = await _getContinueReading();

    // 2. recommended = trending (lấy tầm 10 truyện hot)
    final List<FeedItem> recommendedList = await _getTrending(
      cursor: const FeedCursor(offset: 0, limit: 10),
    );

    // 3. latest updates (lấy tầm 10 truyện mới update)
    final List<FeedItem> latestList = await _getLatestUpdates(
      cursor: const FeedCursor(offset: 0, limit: 10),
    );

    // map progress -> ContinueReadingItemVM
    final continueVMs = progressList.map((p) {
      return ContinueReadingItemVM(
        mangaId: p.mangaId,
        mangaTitle: p.mangaTitle,
        chapterId: p.chapterId,
        chapterNumber: p.chapterNumber,
        pageIndex: p.pageIndex,
        coverImageUrl: p.coverImageUrl,
      );
    }).toList();

    return HomeVM(
      continueReading: continueVMs,
      recommended: recommendedList,
      latestUpdates: latestList,
    );
  }
}
