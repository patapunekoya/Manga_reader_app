// lib/presentation/widgets/chapter_tile.dart
import 'package:flutter/material.dart';
import '../../domain/entities/chapter.dart';

class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;

  const ChapterTile({
    super.key,
    required this.chapter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final timeText = chapter.updatedAt != null
        ? chapter.updatedAt!.toIso8601String()
        : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x22FFFFFF), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: "Chapter ${chapter.chapterNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (chapter.title != null &&
                        chapter.title!.trim().isNotEmpty) ...[
                      const TextSpan(text: " • "),
                      TextSpan(
                        text: chapter.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (timeText.isNotEmpty) ...[
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: timeText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
