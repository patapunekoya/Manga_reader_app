// -----------------------------------------------------------------------------
// LatestUpdatesList
// -----------------------------------------------------------------------------
// Widget hiển thị danh sách "Mới cập nhật" (latest updates) trên màn Home.
//
// Dữ liệu truyền vào:
//   - List<FeedItem> items: danh sách manga lấy từ Discovery module
//   - onTapManga(String mangaId): callback khi user bấm vào một manga
//
// Behavior:
//   - Mỗi item hiển thị dạng list tile: ảnh nhỏ, tên truyện, info cập nhật
//   - Không scroll riêng → dùng shrinkWrap + NeverScrollable để nằm trong
//     1 SingleChildScrollView của Home page.
//   - Nếu không có dữ liệu → in ra "Chưa có cập nhật."
//
// UI style: Dark mode, text trắng, hành vi nhẹ để phù hợp Home screen.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:discovery/domain/entities/feed_item.dart';

class LatestUpdatesList extends StatelessWidget {
  final List<FeedItem> items;

  // Callback mở màn chi tiết hoặc reader dựa trên mangaId
  final void Function(String mangaId) onTapManga;

  const LatestUpdatesList({
    super.key,
    required this.items,
    required this.onTapManga,
  });

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // Khi không có dữ liệu -> hiển thị text nhỏ
    // ------------------------------------------------------------
    if (items.isEmpty) {
      return const Text(
        "Chưa có cập nhật.",
        style: TextStyle(color: Colors.white54),
      );
    }

    // ------------------------------------------------------------
    // Danh sách item, không scroll riêng (NeverScrollableScrollPhysics)
    // ------------------------------------------------------------
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),

      itemBuilder: (context, i) {
        final it = items[i];

        return InkWell(
          onTap: () => onTapManga(it.id),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // Ảnh cover
              // --------------------------------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64,
                  height: 90,
                  color: const Color(0xFF2A2A2D),
                  child: it.coverImageUrl != null
                      ? Image.network(
                          it.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.image,
                          color: Colors.white38,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // --------------------------------------------------
              // Info: Title + last update
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên truyện
                    Text(
                      it.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Dòng phụ: last chapter hoặc updatedAt
                    Text(
                      it.lastChapterOrUpdate ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // Icon điều hướng
              // --------------------------------------------------
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        );
      },
    );
  }
}
