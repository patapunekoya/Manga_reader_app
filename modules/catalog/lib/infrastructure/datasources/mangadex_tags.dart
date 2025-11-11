// ignore_for_file: constant_identifier_names

// ======================================================================
// MangaDex Tag UUIDs
//
// Mục đích:
//   - Map tên thể loại (genre) → UUID của MangaDex.
//   - Dùng cho search với filter "includedTags[]" trong API `/manga`.
//
// Vai trò kiến trúc (Infrastructure):
//   - Đây là hằng số thuần ở tầng infra (datasource).
//   - Repository hoặc RemoteDataSource sẽ tra cứu tagId từ tên genre
//     trước khi gọi API.
//
// Lưu ý API MangaDex:
//   - Mỗi tag (Action, Romance, Comedy…) được định danh bằng UUID cố định.
//   - Để filter theo thể loại: 
//       includedTags[] = <tagUUID>
//       includedTagsMode = AND
//
// Lưu ý mở rộng:
//   - Có thể mở rộng thêm nhiều tag khác nếu cần.
//   - Nên normalize key về lowercase trước khi tra (đã dùng .toLowerCase()).
//
// ======================================================================

const Map<String, String> kMangaDexTagIds = {
  'action'  : '391b0423-d847-456f-aff0-8b0cfc03066b',
  'romance' : '423e2eae-a7a2-4a8b-ac03-a8351462d71d',
  'comedy'  : '4d32cc48-9f00-4cca-9b5a-a839f0764984',
  'drama'   : 'b9af3a63-f058-46de-a9a0-e0c13906197a',
  'fantasy' : 'cdc58593-87dd-415e-bbc0-2ec27bf404cc',
  'horror'  : '3b60b75c-a2d7-4860-ab56-05f391bb888c',
  'mystery' : 'ee968100-4191-4968-93d3-f82d72be7e46',
  'sci-fi'  : '256c8bd9-4904-4360-bf4f-508a76d67183', // sci-fi (Science Fiction)
};
