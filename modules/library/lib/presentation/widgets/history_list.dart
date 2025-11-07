// modules/library/lib/presentation/widgets/history_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/history_bloc.dart';
import '../../domain/entities/reading_progress.dart';

/// HistoryList
///
/// Hiển thị danh sách lịch sử đọc gần nhất (theo CHAPTER đã đọc).
/// Tap -> gọi [onResumeReading] để shell điều hướng sang Reader.
/// Giữ tham số pageIndex = 0 cho tương thích router hiện tại.
class HistoryList extends StatelessWidget {
  final void Function({
    required String chapterId,
    required String mangaId,
    required int pageIndex, // vẫn giữ để tương thích; luôn truyền 0
  })? onResumeReading;

  const HistoryList({
    super.key,
    this.onResumeReading,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        // loading
        if (state.status == HistoryStatus.loading ||
            state.status == HistoryStatus.initial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // failure
        if (state.status == HistoryStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Lỗi tải lịch sử đọc.\n${state.errorMessage ?? ''}",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // success
        final List<ReadingProgress> list = state.history;
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Chưa có lịch sử đọc.",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(
            color: Color(0x22FFFFFF),
            height: 1,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return _HistoryRow(
              item: item,
              onTap: () {
                if (onResumeReading != null) {
                  onResumeReading!(
                    chapterId: item.lastChapterId, // CHAPTER-ONLY
                    mangaId: item.mangaId,
                    pageIndex: 0, // luôn 0 để tương thích
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ReadingProgress item;
  final VoidCallback? onTap;

  const _HistoryRow({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 90,
              child: item.coverImageUrl != null
                  ? Image.network(
                      item.coverImageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 64,
                      height: 90,
                      color: const Color(0xFF2A2A2D),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manga title
                Text(
                  item.mangaTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Chapter (CHAPTER-ONLY)
                Text(
                  "Chapter ${item.lastChapterNumber} • Đã đọc",
                  style: th.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                // Timestamp
                Text(
                  "Lưu lúc ${item.savedAt.toIso8601String()}",
                  style: th.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
