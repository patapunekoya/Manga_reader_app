// -----------------------------------------------------------------------------
// ContinueReadingStrip
// -----------------------------------------------------------------------------
// Widget hiển thị danh sách các truyện "Đọc tiếp" (continue reading).
//
// Data lấy từ HomeVM.continueReading → mỗi item chứa:
//   - mangaId
//   - mangaTitle
//   - chapterId (chương đang đọc dở)
//   - chapterNumber
//   - pageIndex (luôn 0 trong hệ thống mới, để tương thích API cũ)
//   - coverImageUrl
//
// Layout:
//   - Dạng horizontal ListView
//   - Mỗi truyện là 1 card nhỏ, bo góc, có ảnh + tiêu đề + dòng số chương
//
// onTapContinue:
//   Callback khi người dùng bấm vào card → mở đúng chapter dở dang.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:home/domain/entities/home_vm.dart';

class ContinueReadingStrip extends StatelessWidget {
  final List<ContinueReadingItemVM> items;

  // Callback khi user nhấn vào 1 item để đọc tiếp chương đang dang dở
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
    // Nếu không có item nào → ẩn luôn
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // ListView ngang cao ~210px để hình + text không bị chật
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
              // Điều hướng màn reader
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

// -----------------------------------------------------------------------------
// _ContinueCard
// -----------------------------------------------------------------------------
// Card nhỏ hiển thị từng item "Đọc tiếp":
//   - Ảnh cover (chiếm phần lớn diện tích)
//   - Tên manga (1 dòng)
//   - "Chap X • Trang Y"
//
// Có xử lý text scale (accessibility) để tránh vỡ layout khi user tăng font.
// -----------------------------------------------------------------------------
class _ContinueCard extends StatelessWidget {
  final ContinueReadingItemVM item;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp text scale để UI không vỡ khi người dùng bật accessibility quá lớn
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
              // -----------------------------------------------------------------
              // Cover image (Expanded để chiếm hết phần vertical còn lại)
              // -----------------------------------------------------------------
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.coverImageUrl != null &&
                          item.coverImageUrl!.isNotEmpty
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

              // -----------------------------------------------------------------
              // Tên manga: tối đa 1 dòng
              // -----------------------------------------------------------------
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

              // -----------------------------------------------------------------
              // Dòng phụ: "Chap X • Trang Y"
              // -----------------------------------------------------------------
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
