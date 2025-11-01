// lib/domain/entities/page_image.dart
import 'package:equatable/equatable.dart';

/// PageImage là 1 trang trong chapter.
/// Mỗi trang có:
/// - index (thứ tự hiển thị)
/// - url (ảnh gốc để load)
///
/// Tầng presentation sẽ dùng list<PageImage> để build ListView.
class PageImage extends Equatable {
  final int index;
  final String imageUrl; // full URL

  const PageImage({
    required this.index,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [index, imageUrl];
}
