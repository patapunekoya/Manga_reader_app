// lib/domain/value_objects/progress_id.dart
//
// ============================================================================
// VALUE OBJECT: ProgressId
// ============================================================================
//
// Ý nghĩa:
//   - Đây là Value Object đại diện cho "ID của tiến trình đọc".
//   - Ở bản triển khai hiện tại, `value` chính là chapterId.
//   - Khác với FavoriteId (dùng mangaId), ProgressId cho phép track chi tiết
//     dựa trên từng *chương* nếu sau này bạn muốn mở rộng.
//
// Tại sao tách thành VO?
//   • Giảm rủi ro nhầm lẫn String giữa chapterId / mangaId / user input.
//   • Giữ clean domain (DDD) vì ProgressId thể hiện rõ "ý nghĩa"
//     hơn là một String tùy tiện.
//   • Dễ mở rộng: nếu sau này muốn encode thêm pageIndex, timestamp,
//     hay dạng composite key, có thể mở rộng VO mà không phá API.
//
// Dùng ở đâu:
//   - `ReadingProgress.id`
//   - Các thao tác trong LibraryRepositoryImpl liên quan đến lưu / cập nhật
//     tiến trình đọc.
//   - Các usecase đọc tiếp (Continue Reading) để so khớp record chính xác.
//
// Equatable:
//   - Giúp so sánh 2 ProgressId dựa trên giá trị `value`, cần cho Hive,
//     Bloc, và các list operations.
//
// ============================================================================

import 'package:equatable/equatable.dart';

/// ProgressId: dùng chapterId làm id lưu progress đọc.
/// Nếu muốn granular hơn (mỗi chapter track riêng), cái này là xịn.
class ProgressId extends Equatable {
  final String value;
  const ProgressId(this.value);

  @override
  List<Object?> get props => [value];
}
