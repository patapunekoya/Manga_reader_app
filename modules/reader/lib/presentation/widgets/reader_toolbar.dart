// lib/presentation/widgets/reader_toolbar.dart
import 'package:flutter/material.dart';

class ReaderToolbar extends StatelessWidget {
  final VoidCallback onBackToManga;
  final VoidCallback onPrevChapter;
  final VoidCallback onNextChapter;
  final int currentPage;
  final int totalPages;
  final String? chapterLabel; // ví dụ "Ch.123"

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
      // overlay style kiểu blur nền tối đục
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // back
            IconButton(
              onPressed: onBackToManga,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),

            // info ở giữa
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

            // prev / next
            IconButton(
              onPressed: onPrevChapter,
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
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
