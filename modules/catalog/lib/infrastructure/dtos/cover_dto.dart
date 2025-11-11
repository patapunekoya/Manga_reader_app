/// ======================================================================
/// DTO: CoverDTO
///
/// Mục đích:
///   - Đại diện dữ liệu cover_art lấy từ MangaDex (trong relationships[]).
///   - Chỉ chứa đúng phần JSON thô cần thiết để dựng URL.
///   - Không dùng trực tiếp ở UI hoặc Domain; RepositoryImpl sẽ chuyển đổi.
///
/// Nguồn dữ liệu:
///   - Nằm trong relationships của MangaDex response.
///   - Ví dụ:
///       {
///         "type": "cover_art",
///         "attributes": {
///            "fileName": "abcd123.jpg"
///         }
///       }
///
/// Kiến trúc:
///   - Tầng Infrastructure (DTO).
///   - Không chứa logic build URL (phân giải fileName → URL).  
///     Việc build URL thuộc utility khác (vd: buildCoverUrl).
///
/// Lưu ý:
///   - fileName đôi khi không có, nên fallback = ''.
///   - Khi parse Manga, RepositoryImpl sẽ đọc CoverDTO rồi build URL:
///         buildCoverUrl(mangaId, coverDTO.fileName)
///
/// ======================================================================

class CoverDTO {
  final String fileName;

  CoverDTO({required this.fileName});

  factory CoverDTO.fromJson(Map<String, dynamic> rel) {
    // rel = { "type": "cover_art", "attributes": {"fileName": "..."} }
    final attr = rel['attributes'] ?? {};
    return CoverDTO(
      fileName: attr['fileName'] ?? '',
    );
  }
}
