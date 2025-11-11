// modules/catalog/lib/presentation/widgets/chapter_tile.dart

import 'package:flutter/material.dart';
import '../../domain/entities/chapter.dart';

/// ======================================================================
/// WIDGET: ChapterTile
///
/// Mục đích:
///   - Hiển thị 1 item chương trong danh sách chapter.
///   - Cho phép bấm vào để mở reader (qua callback onTap).
///
/// Các thành phần UI:
///   • Title chương: lấy title nếu có, nếu title rỗng → fallback "Ch. <số chương>".
///   • Icon ⭐ nếu đây là chương gần nhất đã đọc (isRead = true).
///   • Language code (ví dụ "en", "vi") nếu chapter có trường ngôn ngữ.
///
/// Props:
///   - chapter    : dữ liệu domain Chapter.
///   - onTap      : callback khi user bấm vào.
///   - isRead     : đánh dấu chương đặc biệt (ví dụ: chương tiếp tục đọc).
///
/// Lưu ý:
///   - Dùng Material + InkWell để có hiệu ứng ripple.
///   - Text overflow ellipsis để tránh vỡ layout.
/// ======================================================================
class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;

  /// isRead = chương này là CHƯƠNG GẦN NHẤT đã đọc của manga (đánh dấu ngôi sao)
  final bool isRead;

  const ChapterTile({
    super.key,
    required this.chapter,
    this.onTap,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // không đổi màu nền khi pressed
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ------------------------------------------------------------
              // Title chương (ưu tiên title, fallback: "Ch <number>")
              // ------------------------------------------------------------
              Expanded(
                child: Text(
                  (chapter.title != null && chapter.title!.trim().isNotEmpty)
                      ? chapter.title!
                      : 'Ch. ${chapter.chapterNumber}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ------------------------------------------------------------
              // Icon ⭐ nếu chương là chương đang đọc gần nhất
              // ------------------------------------------------------------
              if (isRead) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              ],

              // ------------------------------------------------------------
              // Hiện ngôn ngữ (nếu có)
              // ------------------------------------------------------------
              if (chapter.language != null) ...[
                const SizedBox(width: 8),
                Text(
                  chapter.language!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
