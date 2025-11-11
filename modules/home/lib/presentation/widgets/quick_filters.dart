// -----------------------------------------------------------------------------
// QuickFilters
// -----------------------------------------------------------------------------
// Widget hiển thị một hàng các bộ lọc nhanh (quick tags) theo thể loại phổ biến.
// Thường được đặt ngay dưới mục "Continue Reading" trên Home screen.
//
// Mục đích:
//   - Tạo UI filter nhanh, nhẹ, không dùng network.
//   - Khi user bấm vào 1 tag → gọi callback onSelectTag(tag)
//   - Module Home có thể dùng callback này để navigate sang trang Search
//     hoặc bắn event SearchStarted(genre: tag).
//
// Đặc điểm UI:
//   - Dạng horizontal scroll
//   - Badge bo tròn, dark theme, text trắng
//   - Sử dụng ListView.separated cho spacing đồng đều
//
// Không thay đổi code logic—chỉ thêm chú thích.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Thanh filter nhanh theo thể loại phổ biến.
/// UI nhẹ, chưa cần gắn logic network.
/// Gắn ở Home dưới "Continue Reading".
class QuickFilters extends StatelessWidget {
  final List<String> tags;

  // Callback khi user chọn 1 tag → module Home quyết định làm gì tiếp theo
  final void Function(String tag)? onSelectTag;

  const QuickFilters({
    super.key,

    // Default list: một số tag hay gặp trong manga
    this.tags = const [
      "Action",
      "Romance",
      "Isekai",
      "Comedy",
      "Drama",
      "Horror",
    ],
    this.onSelectTag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,

      // -----------------------------------------------------------------------
      // ListView horizontal cho các tag
      // -----------------------------------------------------------------------
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: tags.length,

        itemBuilder: (context, i) {
          final tag = tags[i];

          return GestureDetector(
            onTap: () {
              // Khi bấm vào tag, gửi cho parent xử lý
              if (onSelectTag != null) onSelectTag!(tag);
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              // -----------------------------------------------------------------
              // Styling badge: màu xám tối, bo tròn 999 để ra hình pill
              // -----------------------------------------------------------------
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2D),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF3A3A3F),
                  width: 1,
                ),
              ),

              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
