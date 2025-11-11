// lib/domain/value_objects/at_home_url.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là Value Object dùng để gói thông tin từ API:
//   GET https://api.mangadex.org/at-home/server/{chapterId}
//
// Kết quả API trả về:
//    {
//      "baseUrl": "https://uploads.mangadex.org",
//      "chapter": {
//        "hash": "...",
//        "data": ["page1.jpg", "page2.jpg", ...]
//      }
//    }
//
// VO này giữ 2 giá trị quan trọng:
//   ➤ baseUrl  — URL host nơi chứa ảnh
//   ➤ hash     — mã hash riêng của chapter
//
// Từ đó build ra link đầy đủ cho từng trang ảnh.
// ReaderRepositoryImpl sẽ dùng AtHomeUrl để chuyển thành PageImage.
//
// Ưu điểm:
//   ➤ Giúp domain tách biệt logic build URL khỏi presentation.
//   ➤ Dễ test vì AtHomeUrl là VO thuần không phụ thuộc framework.
//
import 'package:equatable/equatable.dart';

/// AtHomeUrl:
/// ----------
/// Trả về baseUrl + hash dùng để build link ảnh.
/// Ví dụ:
///   final url = atHome.buildPageUrl("0001.jpg");
///   => https://uploads.mangadex.org/data/<hash>/0001.jpg
class AtHomeUrl extends Equatable {
  final String baseUrl;  // host chứa ảnh
  final String hash;     // hash của chapter

  const AtHomeUrl({
    required this.baseUrl,
    required this.hash,
  });

  /// Build link đầy đủ cho 1 fileName (full chất lượng).
  String buildPageUrl(String fileName) {
    return "$baseUrl/data/$hash/$fileName";
  }

  /// Nếu muốn dùng data-saver (ảnh nhẹ hơn):
  ///   "$baseUrl/data-saver/$hash/$fileName"
  ///
  /// Tầng ReaderRepositoryImpl có thể chọn chế độ muốn load.
  @override
  List<Object?> get props => [baseUrl, hash];
}
