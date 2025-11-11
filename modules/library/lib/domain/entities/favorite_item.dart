// lib/domain/entities/favorite_item.dart
//
// =============================================================================
// ENTITY: FavoriteItem
// =============================================================================
// Mục đích:
//   - Đại diện cho **một manga được user đánh dấu yêu thích (Favorite)**.
//   - Đây là Entity thuộc *Domain Layer*, nên hoàn toàn độc lập với UI, Bloc,
//     hoặc DataSource.
//
// Tại sao cần Entity riêng?
//   - Để tách biệt rõ dữ liệu nghiệp vụ (business data) với dữ liệu từ API.
//   - FavoriteItem KHÔNG phụ thuộc vào MangaDex API,
//     vì toàn bộ danh sách favorite được lưu LOCAL (Hive box).
//   - UI chỉ cần đọc các field của Entity để render màn hình Favorites.
//
// Được sử dụng ở đâu?
//   - favorites_bloc.dart (hiển thị danh sách)
//   - ToggleFavorite usecase (thêm/xóa)
//   - LibraryRepository (convert giữa Hive model ↔ Entity)
//   - MangaDetailView (nhấn icon trái tim)
//   - HomeScreen nếu cần list tóm tắt
//
// Các field:
//   • id (FavoriteId): chính là mangaId dạng Value Object → đảm bảo type an toàn.
//   • title: tên manga hiển thị.
//   • coverImageUrl: ảnh bìa (nullable nếu không có).
//   • addedAt: thời điểm user bấm yêu thích lần đầu.
//   • updatedAt: lần chỉnh sửa gần nhất.
//       - Nếu user favorite lại manga đã từng bị xoá/ẩn, updatedAt thay đổi.
//       - UI có thể sort list theo updatedAt để show manga yêu thích gần đây.
//
// copyWith():
//   - Dùng khi muốn update 1 vài field nhưng giữ lại phần còn lại.
//   - Ví dụ: update lại coverImageUrl nếu reload detail.
//
// Equatable:
//   - Đảm bảo so sánh object theo value, giúp Bloc rebuild chính xác,
//     tránh lỗi UI không cập nhật.
//
// =============================================================================

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
