// lib/domain/value_objects/page_index.dart
import 'package:equatable/equatable.dart';

/// PageIndex: vị trí trang hiện tại trong chapter.
/// Dùng value object để tránh nhầm int lẻ lung tung.
class PageIndex extends Equatable {
  final int value;
  const PageIndex(this.value);

  PageIndex next() => PageIndex(value + 1);
  PageIndex prev() => PageIndex(value > 0 ? value - 1 : 0);

  @override
  List<Object?> get props => [value];
}
