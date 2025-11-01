// lib/domain/value_objects/progress_id.dart
import 'package:equatable/equatable.dart';

/// ProgressId: dùng chapterId làm id lưu progress đọc.
/// Nếu muốn granular hơn (mỗi chapter track riêng), cái này là xịn.
class ProgressId extends Equatable {
  final String value;
  const ProgressId(this.value);

  @override
  List<Object?> get props => [value];
}
