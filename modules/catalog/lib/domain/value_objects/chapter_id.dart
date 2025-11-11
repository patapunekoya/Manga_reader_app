// lib/domain/value_objects/chapter_id.dart

import 'package:equatable/equatable.dart';

/// ======================================================================
/// Value Object: ChapterId
///
/// Mục đích:
///   - Đại diện ID của một Chapter trong MangaDex.
///   - Tách ID khỏi string raw để đảm bảo tính an toàn và rõ ràng
///     khi truyền giữa các tầng (Domain / Application / UI).
///
/// Đặc điểm của Value Object:
///   - Bất biến (immutable).
///   - So sánh theo giá trị (Equatable).
///   - Không chứa logic parse hoặc tạo mới từ JSON.
///     Việc tạo VO được thực hiện tại DTO layer (infrastructure).
///
/// Tại sao dùng Value Object:
///   - Tránh nhầm lẫn với id khác (mangaId, authorId…).
///   - Giúp domain rõ ràng hơn và type-safe.
///   - Giảm lỗi “truyền nhầm string”.
///
/// Lưu ý:
///   - Một ChapterId là duy nhất trong MangaDex.
///   - Chỉ giữ raw value, không thêm logic.
/// ======================================================================
class ChapterId extends Equatable {
  final String value;

  const ChapterId(this.value);

  @override
  List<Object?> get props => [value];
}
