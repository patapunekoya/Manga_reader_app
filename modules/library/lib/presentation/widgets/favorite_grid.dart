// lib/presentation/widgets/favorite_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_item.dart';
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == FavoritesStatus.failure) {
          return Center(
            child: Text(
              "Lỗi tải danh sách yêu thích.\n${state.errorMessage ?? ''}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        final list = state.favorites;
        if (list.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có truyện yêu thích.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // mobile 2 cột
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 5,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return _FavoriteCard(
              item: item,
              onTap: () {
                if (onTapManga != null) {
                  onTapManga!(item.id.value);
                }
              },
            );
          },
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback? onTap;

  const _FavoriteCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
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
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
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
          Text(
            "Cập nhật: ${item.updatedAt.toIso8601String()}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: th.textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
