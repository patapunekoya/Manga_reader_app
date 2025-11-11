// lib/domain/entities/cover_art.dart

import 'package:equatable/equatable.dart';

/// ======================================================================
/// Entity: CoverArt
///
/// Mục đích:
///   - Đại diện thông tin ảnh bìa (cover art) của một Manga.
///   - Tách riêng để Domain rõ ràng, dù Manga entity thường sẽ giữ
///     `coverImageUrl` trực tiếp để UI dễ dùng.
///
/// Kiến trúc Domain:
///   - Đây là Entity thuần, không chứa logic parse JSON.
///   - DTO (ở infrastructure) chịu trách nhiệm chuyển từ API → CoverArt.
///   - UI chỉ nhận sẵn `imageUrl` hoàn chỉnh, không cần ghép đường dẫn.
///
/// Thuộc tính:
///   - [imageUrl] : URL đầy đủ của ảnh (đã build xong từ baseUrl + fileName)
///
/// Equatable:
///   - Cho phép so sánh bằng giá trị, cần thiết cho Bloc để tối ưu rebuild.
///
/// Lưu ý:
///   - MangaDex API trả cover dưới dạng `relationships[type=cover_art]`,
///     DTO sẽ chọn fileName đúng resolution và build URL.
///   - Tách CoverArt giúp mở rộng sau này: chất lượng, alt text, blurhash,…
/// ======================================================================
class CoverArt extends Equatable {
  final String imageUrl; // full URL sẵn dùng cho UI

  const CoverArt({
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [imageUrl];
}
