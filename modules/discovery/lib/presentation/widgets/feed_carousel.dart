// lib/presentation/widgets/feed_carousel.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discovery/domain/entities/feed_item.dart';
import 'package:flutter/material.dart';

/// FeedCarousel:
/// - Dùng để render 1 danh sách manga dạng ngang (horizontal scroll)
/// - Thường dùng cho "Trending" hoặc "Latest Updates"
///
/// Thằng Home module có thể import widget này rồi truyền list<FeedItem>.
///
/// UI style: dark mode, card bo góc, text trắng.
class FeedCarousel extends StatelessWidget {
  final String title;
  final List<FeedItem> items;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section title
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 220, // chiều cao tổng của card
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
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover
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
                                    placeholder: (ctx, _) => Container(
                                      color: const Color(0xFF2A2A2D),
                                    ),
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

                      // Title
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

                      // Status + lastChapterOrUpdate
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

                      // Tags (show chỉ 2 tag đầu cho gọn)
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _bgForStatus() {
    // ongoing -> vàng nhẹ, completed -> xanh lá nhẹ, unknown -> xám
    final low = status.toLowerCase();
    if (low.contains('ongoing')) {
      return const Color(0xFF4B3F00); // vàng nâu nhẹ
    }
    if (low.contains('complete')) {
      return const Color(0xFF003F1F); // xanh lá đậm nhẹ
    }
    return const Color(0xFF2A2A2D); // fallback xám
  }

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
