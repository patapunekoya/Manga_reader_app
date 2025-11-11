// lib/domain/value_objects/favorite_id.dart
//
// ============================================================================
// VALUE OBJECT: FavoriteId
// ============================================================================
//
// Mục đích:
//   - Đại diện cho ID của một FavoriteItem.
//   - Thực chất chính là mangaId, nhưng được bao lại thành Value Object (VO)
//     để phân biệt rõ trong domain layer và tránh lẫn với các String khác.
//
// Lợi ích của việc tách VO:
//   • Type-safe hơn: chỗ nào cần FavoriteId thì bắt buộc truyền đúng kiểu.
//   • Dễ mở rộng (validate, parse, normalize ID).
//   • Dễ test ngang hàng (vì implement Equatable).
//   • Giữ Domain theo đúng tư duy DDD.
//
// Dùng ở đâu:
//   - `FavoriteItem.id`
//   - `LibraryRepositoryImpl` khi thao tác hive/sqlite keying.
//   - Logic UI/Usecase không xử lý VO mà chỉ truyền value.
//
// Equatable:
//   - Override == và hashCode dựa trên `value`, giúp so sánh 2 FavoriteId dễ.
//
// ============================================================================

import 'package:equatable/equatable.dart';

/// FavoriteId: chứa mangaId dưới dạng Value Object.
/// Tách riêng để thể hiện "ý nghĩa domain", không phải String tùy tiện.
class FavoriteId extends Equatable {
  final String value;

  const FavoriteId(this.value);

  @override
  List<Object?> get props => [value];
}
