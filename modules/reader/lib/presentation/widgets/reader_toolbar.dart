// lib/presentation/widgets/reader_toolbar.dart
//
// ReaderToolbar: Thanh điều khiển nổi (overlay) đặt ở BOTTOM của màn Reader.
//
// Chức năng chính:
// - Nút BACK: quay lại trang Manga Detail.
// - Nút chuyển chapter trước / chapter sau (Prev / Next).
// - Hiển thị số trang hiện tại (currentPage) và tổng trang (totalPages).
// - Hiển thị nhãn chapter (vd: “Ch.123”) nếu truyền vào.
//
// Toolbar này được gọi từ ReaderScreen, chỉ là UI component,
// không xử lý logic điều hướng hay BLoC, tất cả đều được callback từ cha.
//

import 'package:flutter/material.dart';

class ReaderToolbar extends StatelessWidget {
  /// Callback quay về trang manga detail.
  /// Cha (ReaderScreen) sẽ điều hướng thật.
  final VoidCallback onBackToManga;

  /// Callback chuyển về chapter trước.
  final VoidCallback onPrevChapter;

  /// Callback chuyển sang chapter tiếp theo.
  final VoidCallback onNextChapter;

  /// Trang hiện tại mà người dùng đang xem (0-based index).
  /// UI sẽ hiển thị dạng “currentPage + 1”.
  final int currentPage;

  /// Tổng số trang của chapter.
  /// Dùng để render dạng “1 / totalPages”.
  final int totalPages;

  /// Dòng label hiển thị ở giữa, ví dụ “Ch.123”.
  /// Không bắt buộc.
  final String? chapterLabel;

  const ReaderToolbar({
    super.key,
    required this.onBackToManga,
    required this.onPrevChapter,
    required this.onNextChapter,
    required this.currentPage,
    required this.totalPages,
    this.chapterLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //
      // Background mờ kiểu overlay khi đọc truyện:
      // - màu đen 60% độ mờ
      // - bo tròn phía trên để cảm giác nổi
      //
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false, // không cần safe area phía trên, chỉ cần bottom
        child: Row(
          children: [
            // ---------------------------------------------------------
            // Nút BACK về manga detail
            // ---------------------------------------------------------
            IconButton(
              onPressed: onBackToManga,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),

            // ---------------------------------------------------------
            // KHU VỰC HIỂN THỊ GIỮA:
            // - Chapter label (nếu có)
            // - Số trang hiện tại
            // ---------------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (chapterLabel != null)
                    Text(
                      chapterLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Số trang dạng 1 / N
                  Text(
                    "${currentPage + 1} / $totalPages",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------
            // Prev chapter
            // ---------------------------------------------------------
            IconButton(
              onPressed: onPrevChapter,
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),

            // ---------------------------------------------------------
            // Next chapter
            // ---------------------------------------------------------
            IconButton(
              onPressed: onNextChapter,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
