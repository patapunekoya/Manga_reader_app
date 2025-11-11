import 'package:flutter/material.dart';
import '../../domain/entities/home_section.dart';

/// ---------------------------------------------------------------------------
/// TrendingSectionList
/// ---------------------------------------------------------------------------
/// Widget hiển thị danh sách đề xuất (ví dụ Trending hoặc Latest Updates).
///
/// ĐIỂM QUAN TRỌNG:
/// - Widget này KHÔNG tự gọi HomeBloc.
/// - HomeShellPage sẽ fetch data từ HomeBloc và truyền xuống props:
///     items       → danh sách DiscoveryFeedItemVM
///     isLoading   → cho biết đang tải
///     isError     → cho biết có lỗi
/// - Mục tiêu: giảm coupling, tránh type mismatch HomeState.
///
/// UI:
/// - Loading     → CircularProgressIndicator
/// - Error       → Text lỗi
/// - Empty       → SizedBox.shrink()
/// - Success     → ListView hiển thị từng row manga
/// ---------------------------------------------------------------------------
class TrendingSectionList extends StatelessWidget {
  /// Danh sách item discovery (đã map thành DiscoveryFeedItemVM ở domain)
  final List<DiscoveryFeedItemVM> items;

  /// True nếu đang tải dữ liệu (loading state)
  final bool isLoading;

  /// True nếu HomeBloc trả lỗi (failure state)
  final bool isError;

  /// Callback khi user nhấn vào 1 manga → truyền id ra ngoài
  final void Function(String mangaId) onTapManga;

  const TrendingSectionList({
    super.key,
    required this.items,
    required this.isLoading,
    required this.isError,
    required this.onTapManga,
  });

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 1. Loading
    // -------------------------------------------------------------------------
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // -------------------------------------------------------------------------
    // 2. Lỗi khi load
    // -------------------------------------------------------------------------
    if (isError) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Không tải được danh sách đề xuất.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // 3. Không có dữ liệu
    // -------------------------------------------------------------------------
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // -------------------------------------------------------------------------
    // 4. Render danh sách data
    // ListView.separated → scroll vertical
    // shrinkWrap:true    → không chiếm full height của parent ListView
    // physics NeverScrollable → để page chính scroll, không phải list này
    // -------------------------------------------------------------------------
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _TrendingRow(
          item: item,
          onTap: () => onTapManga(item.mangaId),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// _TrendingRow
/// ---------------------------------------------------------------------------
/// Widget row hiển thị:
/// - cover nhỏ bên trái
/// - title + subtitle bên phải
/// - icon chevron cuối dòng
///
/// Dùng trong TrendingSectionList.
/// ---------------------------------------------------------------------------
class _TrendingRow extends StatelessWidget {
  final DiscoveryFeedItemVM item;
  final VoidCallback onTap;

  const _TrendingRow({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Cover bên trái
          // -------------------------------------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 90,
              child: item.coverImageUrl != null
                  ? Image.network(
                      item.coverImageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFF2A2A2D),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        color: Colors.white38,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // -------------------------------------------------------------------
          // Info text: title + subtitle
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 4),

                // subtitle ví dụ: "Ch.123 • 2h"
                if (item.subLabel != null)
                  Text(
                    item.subLabel!,
                    style: th.textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // Icon mũi tên cuối dòng
          // -------------------------------------------------------------------
          const Icon(
            Icons.chevron_right,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }
}
