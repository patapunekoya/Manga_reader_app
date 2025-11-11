// -----------------------------------------------------------------------------
// RecommendedCarousel
// -----------------------------------------------------------------------------
// Widget carousel dạng PageView để hiển thị danh sách manga được đề xuất
// (recommended / trending). Mỗi item chiếm ~80% chiều ngang để tạo hiệu ứng
// xem dạng slider xoay vòng.
//
// Chức năng chính:
//   - Hiển thị cover + title
//   - Tự động auto-slide sau mỗi 4 giây
//   - User có thể tap vào một card để mở MangaDetail
//
// Kỹ thuật sử dụng:
//   - PageController(viewportFraction: 0.8) → các trang nhỏ hơn full width
//   - Timer.periodic để auto scroll
//   - Stack + gradient overlay để hiển thị title dễ đọc
//
// Không chỉnh logic, chỉ thêm chú thích.
// -----------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:discovery/domain/entities/feed_item.dart';

class RecommendedCarousel extends StatefulWidget {
  final List<FeedItem> items;

  // Callback khi user tap vào manga → gửi mã id ra ngoài
  final void Function(String mangaId) onTapManga;

  const RecommendedCarousel({
    super.key,
    required this.items,
    required this.onTapManga,
  });

  @override
  State<RecommendedCarousel> createState() => _RecommendedCarouselState();
}

class _RecommendedCarouselState extends State<RecommendedCarousel> {
  // PageView controller:
  // viewportFraction = 0.8 giúp các card 2 bên lộ ra một chút → hiệu ứng carousel
  final PageController _pageController = PageController(viewportFraction: 0.8);

  // Timer để auto chuyển trang
  Timer? _autoTimer;

  // index trang hiện tại
  int _current = 0;

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------------------
    // Auto slide mỗi 4 giây
    // -------------------------------------------------------------------------
    _autoTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (widget.items.isEmpty) return;

        // tính trang tiếp theo
        _current = (_current + 1) % widget.items.length;

        // animate PageView sang trang mới
        _pageController.animateToPage(
          _current,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void dispose() {
    // hủy Timer + PageController khi widget dispose
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      // không có data thì ẩn luôn cho gọn UI
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220, // chiều cao tổng thể của carousel
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,

        itemBuilder: (context, index) {
          final it = widget.items[index];

          return GestureDetector(
            onTap: () => widget.onTapManga(it.id),

            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),

              // -----------------------------------------------------------------
              // Card chính: border radius, màu nền tối, có thể có ảnh nền
              // -----------------------------------------------------------------
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1D),
                borderRadius: BorderRadius.circular(16),
                image: it.coverImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(it.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),

              // overlay gradient để chữ không bị chìm vào ảnh
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6), // dưới đậm → giúp đọc text
                      Colors.transparent,             // trên mờ
                    ],
                  ),
                ),

                // text title nằm tại bottom-left
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
