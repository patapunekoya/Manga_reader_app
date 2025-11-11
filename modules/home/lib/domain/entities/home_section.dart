import 'package:equatable/equatable.dart';

/// -----------------------------------------------------------------------------
/// NOTE GIẢI THÍCH FILE
/// -----------------------------------------------------------------------------
/// Đây là file định nghĩa các **ViewModel** được dùng bởi màn hình Home.
/// ViewModel khác Entity ở chỗ:
/// - Entity là dữ liệu domain “thuần”, tách biệt UI.
/// - ViewModel là dữ liệu đã format / gom nhóm theo nhu cầu UI.
///
/// Các ViewModel ở đây:
/// 1) HomeSection               → Gom 2 phần: ContinueReading + DiscoveryFeed
/// 2) ContinueReadingItemVM     → Item cho khu vực “Đọc tiếp”
/// 3) DiscoveryFeedItemVM       → Item cho khu vực “Đang hot / Trending”
///
/// File này **không xử lý logic**, chỉ giữ cấu trúc dữ liệu sạch để Home UI
/// render nhanh và rõ ràng.
/// -----------------------------------------------------------------------------

/// -----------------------------------------------------------------------------
/// HomeSection
/// -----------------------------------------------------------------------------
/// Đây là container lớn của Home.
/// Home UI chỉ cần lấy:
///   vm.continueReading
///   vm.discoveryFeed
/// để dựng các section tương ứng.
class HomeSection extends Equatable {
  final List<ContinueReadingItemVM> continueReading;
  final List<DiscoveryFeedItemVM> discoveryFeed;

  const HomeSection({
    required this.continueReading,
    required this.discoveryFeed,
  });

  @override
  List<Object?> get props => [
        continueReading,
        discoveryFeed,
      ];
}

/// -----------------------------------------------------------------------------
/// ContinueReadingItemVM
/// -----------------------------------------------------------------------------
/// Đây là model dành riêng cho UI của “Continue Reading”.
///
/// Dữ liệu lấy từ ReadingProgress (local Hive):
/// - mangaId          → để mở đúng truyện
/// - mangaTitle       → hiển thị trên card
/// - chapterId        → mở chương đang đọc dở
/// - chapterNumber    → ví dụ: "12"
/// - pageIndex        → luôn = 0 (vì phiên bản mới đọc theo chapter)
/// - coverImageUrl    → ảnh bìa
/// -----------------------------------------------------------------------------
class ContinueReadingItemVM extends Equatable {
  final String mangaId;
  final String mangaTitle;
  final String chapterId;
  final String chapterNumber;
  final int pageIndex;
  final String? coverImageUrl;

  const ContinueReadingItemVM({
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterId,
    required this.chapterNumber,
    required this.pageIndex,
    required this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        mangaId,
        mangaTitle,
        chapterId,
        chapterNumber,
        pageIndex,
        coverImageUrl,
      ];
}

/// -----------------------------------------------------------------------------
/// DiscoveryFeedItemVM
/// -----------------------------------------------------------------------------
/// Model gọn nhẹ để UI hiển thị các item Trending hoặc Latest Updates.
///
/// - mangaId         → dùng navigate
/// - title           → tên truyện
/// - coverImageUrl   → ảnh bìa 256.jpg hoặc null
/// - subLabel        → ví dụ: "Ch.123" hoặc "2025-11-01"
///
/// UI chỉ cần vừa đủ để render card trên Home.
/// -----------------------------------------------------------------------------
class DiscoveryFeedItemVM extends Equatable {
  final String mangaId;
  final String title;
  final String? coverImageUrl;
  final String? subLabel;

  const DiscoveryFeedItemVM({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
    required this.subLabel,
  });

  @override
  List<Object?> get props => [
        mangaId,
        title,
        coverImageUrl,
        subLabel,
      ];
}
