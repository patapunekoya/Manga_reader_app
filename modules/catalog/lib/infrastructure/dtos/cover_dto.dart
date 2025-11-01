/// Dto cho "cover_art" relationship trong MangaDex
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
