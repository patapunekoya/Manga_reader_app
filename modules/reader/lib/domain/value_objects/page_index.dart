// lib/domain/value_objects/page_index.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là Value Object đại diện cho **chỉ số trang hiện tại** trong 1 chapter.
// Thay vì dùng int lung tung (dễ nhầm lẫn, dễ out-of-range),
// ta gom nó thành 1 kiểu riêng: PageIndex.
//
// Lợi ích của Value Object PageIndex:
//   ✅ Giúp code rõ ràng hơn: mọi biến pageIndex đều là PageIndex, không phải int rời.
//   ✅ Có hàm next() / prev() để tăng giảm hợp lệ, tránh lùi dưới 0.
//   ✅ Dùng Equatable để hỗ trợ so sánh trong Bloc (state update).
//
// VD sử dụng trong ReaderBloc:
//   var newIndex = currentIndex.next();
//   emit(state.copyWith(pageIndex: newIndex));
//
// Hoặc
//   if (pageIndex.value == lastPage) ...
//
import 'package:equatable/equatable.dart';

/// PageIndex:
/// ----------
/// Đại diện cho vị trí trang trong chapter.
/// Bao bọc int để tránh dùng nhầm và có tiện ích next/prev.
class PageIndex extends Equatable {
  final int value;
  const PageIndex(this.value);

  /// Tăng index lên 1
  PageIndex next() => PageIndex(value + 1);

  /// Giảm index, nhưng không bao giờ nhỏ hơn 0
  PageIndex prev() => PageIndex(value > 0 ? value - 1 : 0);

  @override
  List<Object?> get props => [value];
}
