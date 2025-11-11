// lib/domain/entities/page_image.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là entity PageImage dùng trong module READER.
//
// Vai trò:
//   ➤ Đại diện cho 1 TRANG ẢNH trong 1 CHAPTER.
//   ➤ ReaderBloc & ReaderView sẽ nhận List<PageImage>
//     để hiển thị thành danh sách ảnh.
//
// Thành phần:
//   - index: vị trí trang (0, 1, 2, ...)
//   - imageUrl: link ảnh gốc MangaDex (full URL)
//
// Tầng nào dùng?
//   ➤ ReaderRepositoryImpl trả ra List<PageImage>
//   ➤ GetChapterPages usecase cung cấp cho ReaderBloc
//   ➤ Reader UI hiển thị ảnh theo thứ tự index
//
// Lợi ích khi tách entity riêng:
//   ➤ Loại bỏ sự phụ thuộc JSON vào UI.
//   ➤ Dễ sửa đổi cấu trúc dữ liệu nếu sau này thay đổi API.
//   ➤ Equatable hỗ trợ so sánh nhanh trong Bloc.
//
import 'package:equatable/equatable.dart';

/// PageImage:
/// ----------
/// Đại diện cho 1 trang ảnh của chapter.
/// Presentation sẽ dùng nó để render ảnh trong danh sách.
class PageImage extends Equatable {
  /// index trang trong chapter
  final int index;

  /// URL ảnh đầy đủ (đã được build từ reader repo)
  final String imageUrl;

  const PageImage({
    required this.index,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [index, imageUrl];
}
