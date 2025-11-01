// lib/presentation/widgets/quick_filters.dart
import 'package:flutter/material.dart';

/// Thanh filter nhanh theo thể loại phổ biến.
/// UI nhẹ, chưa cần gắn logic network.
/// Gắn ở Home dưới "Continue Reading".
class QuickFilters extends StatelessWidget {
  final List<String> tags;
  final void Function(String tag)? onSelectTag;

  const QuickFilters({
    super.key,
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
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: tags.length,
        itemBuilder: (context, i) {
          final tag = tags[i];
          return GestureDetector(
            onTap: () {
              if (onSelectTag != null) onSelectTag!(tag);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
