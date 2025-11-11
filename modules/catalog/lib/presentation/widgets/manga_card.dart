// lib/presentation/widgets/manga_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/manga.dart';

/// ======================================================================
/// WIDGET: MangaCard
///
/// Mục đích:
///   - Hiển thị 1 thẻ manga trong Grid/List: ảnh bìa, tiêu đề, trạng thái,
///     và thông tin phụ (tag đầu tiên / năm).
///   - Cho phép bấm (onTap) để điều hướng tới chi tiết.
///
/// Thiết kế & hành vi:
///   • Bố cục dọc: Cover (3:4) → khoảng cách → Text block.
///   • `mainAxisSize: min` để thẻ không cố “kéo giãn” full chiều cao ô grid.
///   • Ảnh bìa dùng `CachedNetworkImage`:
///       - placeholder nền tối khi đang tải
///       - errorWidget khi lỗi tải ảnh
///   • Text block:
///       - Title: tối đa 2 dòng, ellipsis
///       - Hàng phụ 16px cao cố định: pill trạng thái + subtext (tag/năm)
///
/// Lý do chọn `Flexible` thay vì `Expanded` cho text block:
///   - Trong Grid, `Expanded` có thể ép cột cao bằng nhau gây tràn.
///   - `Flexible(FlexFit.loose)` cho phép nội dung co vừa đủ.
///
/// Props:
///   - [manga] : entity Manga đã map sẵn cho UI.
///   - [onTap] : callback khi người dùng bấm vào card.
/// ======================================================================
class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback? onTap;

  const MangaCard({
    super.key,
    required this.manga,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        // QUAN TRỌNG:
        // dùng min để card không cố giãn full chiều cao ô Grid.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== COVER ====================================================
          // Tỉ lệ 3:4 phổ biến với bìa manga. Bo góc 12 cho cảm giác mềm.
          // CachedNetworkImage: cache + placeholder + error widget.
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: manga.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: manga.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF2A2A2D),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white38,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF2A2A2D),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // ===== TEXT BLOCK ==============================================
          // Không dùng Expanded ở đây vì trong Grid Expanded sẽ đòi full chiều cao.
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min, // <-- tránh tự kéo cao
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: ưu tiên đọc dễ, 2 dòng, chữ đậm vừa phải.
                Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                // Hàng phụ cao 16px để các card đồng đều chiều cao.
                // Gồm: pill trạng thái + subtext (tag đầu tiên / năm)
                SizedBox(
                  height: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _StatusPill(status: manga.status),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _buildSubText(manga),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: th.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 11,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng chuỗi subtext:
  ///   - Nếu có tag đầu tiên và year → "Tag • Year"
  ///   - Nếu chỉ có tag → "Tag"
  ///   - Nếu chỉ có year → "Year"
  ///   - Mặc định rỗng để UI gọn gàng khi thiếu dữ liệu.
  String _buildSubText(Manga m) {
    // ví dụ hiển thị: "Action • 2022"
    final tag0 = m.tags.isNotEmpty ? m.tags.first : null;
    if (tag0 != null && m.year != null) {
      return "$tag0 • ${m.year}";
    } else if (tag0 != null) {
      return tag0;
    } else if (m.year != null) {
      return "${m.year}";
    }
    return '';
  }
}

/// ======================================================================
/// SUB-WIDGET: _StatusPill
///
/// Mục đích:
///   - Hiển thị trạng thái manga dạng "chip" nhỏ: ongoing / completed / other.
///   - Màu nền/chữ được chọn thủ công để đủ tương phản nền tối.
///
/// Quy tắc màu đơn giản:
///   - chứa "ongoing"   → vàng nâu (nền) + vàng nhạt (chữ)
///   - chứa "complete"  → xanh lá đậm (nền) + xanh lá nhạt (chữ)
///   - khác             → xám đậm (nền) + trắng mờ (chữ)
///
/// Lưu ý:
///   - Dùng `contains` (lowercase) cho tính linh hoạt chuỗi trạng thái.
///   - Bo góc 6, padding nhỏ để giữ mật độ thông tin.
/// ======================================================================
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final low = status.toLowerCase();
    Color bg;
    Color fg;

    if (low.contains('ongoing')) {
      bg = const Color(0xFF4B3F00);
      fg = const Color(0xFFFFF59D);
    } else if (low.contains('complete')) {
      bg = const Color(0xFF003F1F);
      fg = const Color(0xFF80E27E);
    } else {
      bg = const Color(0xFF2A2A2D);
      fg = Colors.white70;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
      ),
    );
  }
}
