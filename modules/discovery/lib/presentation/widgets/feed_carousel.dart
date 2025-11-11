// lib/presentation/widgets/feed_carousel.dart
//
// -----------------------------------------------------------------------------
// FeedCarousel
// -----------------------------------------------------------------------------
// Chức năng file:
// - Định nghĩa widget hiển thị danh sách manga dạng băng chuyền ngang
//   (horizontal ListView) dùng cho các section như "Trending", "Latest Updates".
// - Chỉ nhận vào dữ liệu rút gọn FeedItem từ domain discovery.
//
// Kiến trúc & vai trò:
// - Thuần UI (presentation/widgets). Không gọi API, không chứa logic business.
// - Nhận list<FeedItem> + callback onTapItem để màn hình cha điều hướng.
// - Tái sử dụng được ở nhiều nơi (home, chuyên mục, v.v.)
//
// Quy ước hiển thị:
// - Nền tối, chữ sáng, card bo góc.
// - Mỗi item gồm: cover 3:4, tiêu đề 2 dòng, trạng thái + lastChapter/update,
//   và tối đa 2 tag.
//
// Lưu ý hiệu năng:
// - Dùng CachedNetworkImage để cache ảnh bìa.
// - ListView.separated để có khoảng cách giữa item, tiết kiệm widget.
// -----------------------------------------------------------------------------

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:flutter/material.dart';

/// FeedCarousel:
/// - Widget section gồm tiêu đề + list ngang các thẻ manga.
/// - Thích hợp để nhúng vào trang Home hoặc màn "Khám phá".
class FeedCarousel extends StatelessWidget {
  /// Tiêu đề section: ví dụ "Trending" hoặc "Latest Updates".
  final String title;

  /// Dữ liệu hiển thị: mỗi phần tử là FeedItem rút gọn (id, title, cover...).
  final List<FeedItem> items;

  /// Callback khi bấm vào 1 item: trả về mangaId để cha tự điều hướng.
  final void Function(String mangaId)? onTapItem;

  const FeedCarousel({
    super.key,
    required this.title,
    required this.items,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Trạng thái rỗng: vẫn hiển thị tiêu đề + dòng thông báo
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Không có dữ liệu.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    // Trạng thái có dữ liệu: tiêu đề + list ngang
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------- Header: Section title --------------------
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // -------------------- List ngang các card ----------------------
        // Chiều cao cố định để giữ layout ổn định (cover 3:4 + text)
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final it = items[index];

              return GestureDetector(
                onTap: () {
                  if (onTapItem != null) {
                    onTapItem!(it.id);
                  }
                },
                child: SizedBox(
                  width: 140, // Độ rộng mỗi card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- Cover 3:4 bo góc ----------------
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: const Color(0xFF1A1A1D),
                            child: it.coverImageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: it.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    // Placeholder đơn giản cho lúc load ảnh
                                    placeholder: (ctx, _) => Container(
                                      color: const Color(0xFF2A2A2D),
                                    ),
                                    // Nếu lỗi ảnh: icon báo lỗi
                                    errorWidget: (ctx, _, __) => Container(
                                      color: Colors.black26,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white30,
                                      ),
                                    ),
                                  )
                                : Container(
                                    // Không có cover -> placeholder
                                    color: const Color(0xFF2A2A2D),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.photo,
                                      color: Colors.white30,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // -------------------- Tiêu đề 2 dòng --------------
                      Text(
                        it.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ---- Hàng trạng thái + lastChapter/updatedAt -----
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusBadge(
                            status: it.status,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              it.lastChapterOrUpdate ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // -------------------- Tag pills (tối đa 2) --------
                      // Gọn, không chiếm quá nhiều chiều cao.
                      Wrap(
                        spacing: 4,
                        runSpacing: -4,
                        children: it.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2D),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// _StatusBadge: pill nhỏ hiển thị trạng thái (ongoing/completed/khác)
// - Màu nền/ chữ được chọn đơn giản dựa theo chuỗi status.
// - Tách riêng để tái sử dụng trong nhiều nơi nếu cần.
// -----------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  // Chọn màu nền theo status
  Color _bgForStatus() {
    // ongoing -> vàng nâu; completed -> xanh lá; khác -> xám
    final low = status.toLowerCase();
    if (low.contains('ongoing')) {
      return const Color(0xFF4B3F00); // vàng nâu nhẹ
    }
    if (low.contains('complete')) {
      return const Color(0xFF003F1F); // xanh lá đậm nhẹ
    }
    return const Color(0xFF2A2A2D); // fallback xám
  }

  // Chọn màu chữ theo status
  Color _fgForStatus() {
    final low = status.toLowerCase();
    if (low.contains('ongoing')) {
      return const Color(0xFFFFF59D); // vàng nhạt
    }
    if (low.contains('complete')) {
      return const Color(0xFF80E27E); // xanh lá nhạt
    }
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _bgForStatus(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _fgForStatus(),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
