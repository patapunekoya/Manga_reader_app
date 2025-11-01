import 'package:flutter/material.dart';
import 'package:discovery/domain/entities/feed_item.dart';

class LatestUpdatesList extends StatelessWidget {
  final List<FeedItem> items;
  final void Function(String mangaId) onTapManga;

  const LatestUpdatesList({
    super.key,
    required this.items,
    required this.onTapManga,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        "Chưa có cập nhật.",
        style: TextStyle(color: Colors.white54),
      );
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        );
      },
    );
  }
}
