import 'package:flutter/material.dart';
import '../../domain/entities/home_section.dart';

/// Widget hiển thị danh sách đề xuất (trending / latest)
/// KHÔNG còn tự đọc HomeBloc trực tiếp.
/// Cha (HomeShellPage) sẽ đưa data xuống.
/// -> Giảm lỗi type mismatch với HomeBloc/HomeState.
class TrendingSectionList extends StatelessWidget {
  /// danh sách item discovery (đã map thành DiscoveryFeedItemVM)
  final List<DiscoveryFeedItemVM> items;

  /// trạng thái loading
  final bool isLoading;

  /// trạng thái lỗi
  final bool isError;

  /// callback khi bấm vào 1 manga
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
    // 1. loading
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. error
    if (isError) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Không tải được danh sách đề xuất.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // 3. empty
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // 4. list data
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
          // cover ảnh nhỏ bên trái
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

          // text info
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

                // subtitle (ví dụ "Ch.123 • 2h")
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

          const Icon(
            Icons.chevron_right,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }
}
