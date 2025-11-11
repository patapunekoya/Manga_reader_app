// home/application/usecases/build_home_vm.dart
//
// -----------------------------------------------------------------------------
// NOTE GIẢI THÍCH FILE
// -----------------------------------------------------------------------------
// Usecase này chịu trách nhiệm **gom toàn bộ dữ liệu cần thiết để hiển thị
// màn hình Home** của app.
//
// Home cần 3 khối thông tin chính:
// 1) Continue Reading  (truyện đang đọc dở - lấy từ local Hive)
// 2) Recommended       (truyện trending, dữ liệu từ Discovery module)
// 3) Latest Updates    (truyện vừa cập nhật, từ Discovery module)
//
// BuildHomeVM gọi đồng thời 3 nguồn dữ liệu đó rồi trả về HomeVM,
// một ViewModel tổng hợp cho UI.
//
// Đây là kiến trúc clean:
// - UI (HomePage) gọi usecase này -> nhận HomeVM -> build UI.
// - Không để UI tự đi gọi 3 nơi khác nhau.
// -----------------------------------------------------------------------------

import 'package:home/domain/entities/home_vm.dart';

// lịch sử đọc (local)
import 'package:library_manga/application/usecases/get_continue_reading.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';

// trending & latest from discovery
import 'package:discovery/application/usecases/get_trending.dart';
import 'package:discovery/application/usecases/get_latest_updates.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:discovery/domain/value_objects/feed_cursor.dart';

/// ---------------------------------------------------------------------------
/// BuildHomeVM
/// ---------------------------------------------------------------------------
/// Chức năng:
/// - Tập hợp đủ dữ liệu để render Home screen.
/// - Dùng 3 usecase:
///     • GetContinueReading   -> lấy tiến trình đọc từ local Hive
///     • GetTrending          -> lấy danh sách manga hot / trending
///     • GetLatestUpdates     -> lấy manga mới cập nhật
///
/// Luồng hoạt động:
/// - Gọi 3 nguồn dữ liệu tuần tự (có thể future.wait để song song).
/// - Map ReadingProgress -> ContinueReadingItemVM.
/// - Gói vào HomeVM trả cho UI.
///
/// Tầng UI chỉ cần:
///     final vm = await buildHomeVM();
/// rồi vm.continueReading / vm.recommended / vm.latestUpdates.
/// ----------------------------------------------------------------------------
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
    // -------------------------------------------------------------------------
    // 1) LỊCH SỬ ĐỌC TỪ LOCAL
    // -------------------------------------------------------------------------
    // Repo đã sort savedAt desc → truyện đọc gần nhất lên đầu.
    final List<ReadingProgress> progressList = await _getContinueReading();

    // -------------------------------------------------------------------------
    // 2) DANH SÁCH TRENDING
    // -------------------------------------------------------------------------
    // Lấy khoảng 10 truyện đang hot nhất.
    final List<FeedItem> recommendedList = await _getTrending(
      cursor: const FeedCursor(offset: 0, limit: 20),
    );

    // -------------------------------------------------------------------------
    // 3) DANH SÁCH TRUYỆN MỚI CẬP NHẬT
    // -------------------------------------------------------------------------
    final List<FeedItem> latestList = await _getLatestUpdates(
      cursor: const FeedCursor(offset: 0, limit: 15),
    );

    // -------------------------------------------------------------------------
    // MAP ReadingProgress -> ContinueReadingItemVM
    // -------------------------------------------------------------------------
    // Sử dụng lastChapterId + lastChapterNumber (pageIndex bỏ mặc định = 0).
    final continueVMs = progressList.map((p) {
      return ContinueReadingItemVM(
        mangaId: p.mangaId,
        mangaTitle: p.mangaTitle,
        chapterId: p.lastChapterId,
        chapterNumber: p.lastChapterNumber,
        pageIndex: 0, // tương thích schema cũ
        coverImageUrl: p.coverImageUrl,
      );
    }).toList();

    // -------------------------------------------------------------------------
    // TRẢ VỀ VIEWMODEL TỔNG HỢP CHO HOME
    // -------------------------------------------------------------------------
    return HomeVM(
      continueReading: continueVMs,
      recommended: recommendedList,
      latestUpdates: latestList,
    );
  }
}
