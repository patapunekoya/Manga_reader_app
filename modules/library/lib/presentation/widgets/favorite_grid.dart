// packages/library_manga/lib/presentation/widgets/favorite_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';

class FavoriteGrid extends StatelessWidget {
  final void Function(String mangaId)? onTapManga;

  const FavoriteGrid({
    super.key,
    this.onTapManga,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading ||
            state.status == FavoritesStatus.initial) {
          return const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == FavoritesStatus.failure) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Lỗi tải danh sách yêu thích.\n${state.errorMessage ?? ''}",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          );
        }

        final items = state.items; // đảm bảo FavoritesState có 'items'
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Chưa có truyện yêu thích.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        // ✅ Không tự cuộn + tính chiều cao theo nội dung
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 5, // ảnh 3:4 + phần text
          ),
          itemBuilder: (context, index) {
            final it = items[index];
            return GestureDetector(
              onTap: () => onTapManga?.call(it.id.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: it.coverImageUrl != null
                          ? Image.network(it.coverImageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF2A2A2D),
                              alignment: Alignment.center,
                              child: const Icon(Icons.menu_book_rounded,
                                  color: Colors.white38, size: 28),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
