// modules/library/lib/presentation/widgets/history_list.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// HistoryList là widget hiển thị danh sách lịch sử đọc gần nhất theo CHAPTER.
// Nó lắng nghe HistoryBloc để render 4 trạng thái: initial, loading, success, failure.
// Khi người dùng chạm vào một item, widget phát callback onResumeReading(...) để
// màn shell điều hướng tới Reader. Tham số pageIndex được giữ lại cho tương thích router,
// nhưng luôn truyền 0 vì mô hình mới lưu tiến trình theo CHAPTER, không lưu theo trang.
//
// PHỤ THUỘC/LIÊN QUAN
// --------------------
// - HistoryBloc/HistoryState/HistoryEvent: quản lý luồng load history, xóa toàn bộ progress.
// - ReadingProgress (domain): chứa mangaId, mangaTitle, coverImageUrl, lastChapterId,
//   lastChapterNumber, savedAt. Chính là dữ liệu render mỗi hàng.
//
// LUỒNG HOẠT ĐỘNG
// ---------------
// 1) UI parent cung cấp BlocProvider<HistoryBloc> và bắn HistoryLoadRequested() ở ngoài.
// 2) BlocBuilder ở đây lắng nghe state:
//    - initial/loading  -> hiển thị CircularProgressIndicator
//    - failure          -> hiển thị lỗi
//    - success          -> nếu list rỗng thì hiển thị hint; ngược lại render list
// 3) Khi người dùng tap 1 item: gọi onResumeReading(chapterId, mangaId, pageIndex: 0).
//
// GHI CHÚ UI/UX
// -------------
// - ListView.separated để có divider nhẹ giữa các dòng.
// - Mỗi dòng gồm thumbnail 64x90 bo góc + thông tin tiêu đề, chapter, timestamp ISO.
// - Thời gian dùng toIso8601String() để dễ debug; nếu muốn đẹp, format ở lớp hiển thị.
//
// LƯU Ý TÍCH HỢP
// --------------
// - Bên ngoài phải cấp HistoryBloc và trigger load; widget này không tự add event.
// - Nếu muốn hỗ trợ “Xóa tất cả lịch sử”, bắn HistoryClearAllRequested() ở màn cha và
//   để bloc refresh lại state, HistoryList sẽ tự render theo state mới.
//

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
    // BlocBuilder lắng nghe HistoryBloc để quyết định UI theo state
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        // 1) loading / initial -> progress indicator
        if (state.status == HistoryStatus.loading ||
            state.status == HistoryStatus.initial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2) failure -> báo lỗi
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

        // 3) success -> render danh sách hoặc hint rỗng
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

        // 4) render danh sách (không tự cuộn, giao việc cuộn cho cha)
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
          // Thumbnail cover 64x90, bo góc 8
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

          // Khối thông tin: tiêu đề, chapter gần nhất, timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manga title: 2 dòng, đậm
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

                // Dòng phụ: Chapter (CHAPTER-ONLY)
                Text(
                  "Chapter ${item.lastChapterNumber} • Đã đọc",
                  style: th.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                // Timestamp lưu tiến trình (ISO để debug thuận tiện)
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
