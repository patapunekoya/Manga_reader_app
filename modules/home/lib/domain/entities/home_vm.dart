// home/domain/entities/home_vm.dart
//
// ============================== NOTE GIẢI THÍCH FILE ==============================
// File này định nghĩa các View Model (VM) phục vụ riêng cho màn hình Home.
// - VM khác với Entity domain ở chỗ: nó đã được "chuẩn bị" đúng format UI cần,
//   tránh để UI phải tự map/ghép dữ liệu.
// - Ở đây có 2 nhóm:
//    1) ContinueReadingItemVM: item cho khu vực "Đọc tiếp" (progress local).
//    2) HomeVM: container tổng hợp các section hiển thị ở Home gồm
//       - continueReading: danh sách đang đọc dở (local)
//       - recommended: danh sách gợi ý (trending) lấy từ Discovery
//       - latestUpdates: danh sách cập nhật mới (Discovery)
//
// Lưu ý:
// - Với phần Discovery, ta dùng luôn FeedItem (entity từ module discovery) thay vì
//   tạo thêm VM trung gian, để giảm map không cần thiết. Nếu sau này UI cần khác
//   format, có thể bổ sung VM riêng cho Discovery.
//
// Mục tiêu: dữ liệu vào UI gọn, minh bạch, testable.
// ==================================================================================

import 'package:equatable/equatable.dart';

// từ module discovery (dùng trực tiếp cho recommended/latest)
import 'package:discovery/domain/entities/feed_item.dart';

// ========================================================================
// ContinueReadingItemVM
// ------------------------------------------------------------------------
// Đại diện một "thẻ" tiến trình đọc cho Home section "Đọc tiếp":
// - mangaId: điều hướng về chi tiết/reader.
// - mangaTitle: tiêu đề hiện trên card.
// - chapterId: chương đang đọc dở (để mở lại).
// - chapterNumber: hiển thị nhanh "Ch. xx".
// - pageIndex: hiện giữ 0 vì version mới đọc theo chapter, vẫn giữ để tương thích.
// - coverImageUrl: ảnh bìa nếu có.
// Dữ liệu nguồn: ReadingProgress (local storage/Hive) được map sang VM này.
// ========================================================================
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

// ========================================================================
// HomeVM
// ------------------------------------------------------------------------
// View model tổng hợp cho Home:
// - continueReading: danh sách ngang "Đọc tiếp" (nguồn local).
// - recommended: danh sách gợi ý (carousel) → sử dụng FeedItem từ Discovery.
// - latestUpdates: danh sách cập nhật mới (list dọc) → cũng FeedItem.
// Lợi ích:
// - HomeBloc/usecase chỉ cần build 1 object HomeVM là UI có đủ dữ liệu.
// - Đảm bảo Equatable để so sánh state rẻ và tránh rebuild thừa trong UI.
// ========================================================================
class HomeVM extends Equatable {
  final List<ContinueReadingItemVM> continueReading; // section ngang
  final List<FeedItem> recommended;                  // carousel (trending)
  final List<FeedItem> latestUpdates;                // list dọc (latest)

  const HomeVM({
    required this.continueReading,
    required this.recommended,
    required this.latestUpdates,
  });

  @override
  List<Object?> get props => [
        continueReading,
        recommended,
        latestUpdates,
      ];
}
