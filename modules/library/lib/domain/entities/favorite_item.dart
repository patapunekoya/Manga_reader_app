// lib/domain/entities/favorite_item.dart
import 'package:equatable/equatable.dart';
import '../value_objects/favorite_id.dart';

/// FavoriteItem: manga mà user đánh dấu yêu thích.
/// Lưu local để render offline.
/// Các field dùng để hiển thị grid Favorites.
class FavoriteItem extends Equatable {
  final FavoriteId id;          // mangaId
  final String title;
  final String? coverImageUrl;
  final DateTime addedAt;       // khi user bấm yêu thích
  final DateTime updatedAt;     // cập nhật gần nhất (để sort recent)

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.addedAt,
    required this.updatedAt,
  });

  FavoriteItem copyWith({
    String? title,
    String? coverImageUrl,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return FavoriteItem(
      id: id,
      title: title ?? this.title,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        coverImageUrl,
        addedAt,
        updatedAt,
      ];
}
