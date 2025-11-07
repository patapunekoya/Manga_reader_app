// modules/catalog/lib/presentation/widgets/chapter_tile.dart
import 'package:flutter/material.dart';
import '../../domain/entities/chapter.dart';

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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // tiêu đề chương
              Expanded(
                child: Text(
                  (chapter.title != null && chapter.title!.trim().isNotEmpty)
                      ? chapter.title!
                      : 'Ch. ${chapter.chapterNumber}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // icon “đã đọc” (ngôi sao)
              if (isRead) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              ],

              // (tuỳ chọn) ngôn ngữ
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
