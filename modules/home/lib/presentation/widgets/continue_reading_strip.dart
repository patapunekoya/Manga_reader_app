import 'package:flutter/material.dart';
import 'package:home/domain/entities/home_vm.dart';

class ContinueReadingStrip extends StatelessWidget {
  final List<ContinueReadingItemVM> items;
  final void Function({
    required String mangaId,
    required String chapterId,
    required int pageIndex,
  }) onTapContinue;

  const ContinueReadingStrip({
    super.key,
    required this.items,
    required this.onTapContinue,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 0,
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _ContinueCard(
            item: item,
            onTap: () {
              onTapContinue(
                mangaId: item.mangaId,
                chapterId: item.chapterId,
                pageIndex: item.pageIndex,
              );
            },
          );
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final ContinueReadingItemVM item;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.coverImageUrl != null
                    ? Image.network(
                        item.coverImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFF2A2A2D),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white38,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.mangaTitle,
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
              "Chap ${item.chapterNumber} • Trang ${item.pageIndex + 1}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
