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
      return const SizedBox.shrink();
    }

    // Tăng nhẹ chiều cao để dư địa cho text; ảnh sẽ co giãn theo Expanded
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
    // Nếu người dùng bật text scale quá lớn, clamp lại để tránh tràn
    final media = MediaQuery.of(context);
    final clamped = media.textScaler.clamp(maxScaleFactor: 1.2);

    return MediaQuery(
      data: media.copyWith(textScaler: clamped),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh chiếm phần còn lại -> không tràn
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          item.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2A2A2D),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white38,
                            ),
                          ),
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

              // Tiêu đề: tối đa 1 dòng
              Text(
                item.mangaTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),

              // Dòng phụ: 1 dòng
              Text(
                "Chap ${item.chapterNumber} • Trang ${item.pageIndex + 1}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
