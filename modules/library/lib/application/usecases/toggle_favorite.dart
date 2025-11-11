// lib/application/usecases/toggle_favorite.dart
//
// ============================================================================
// USECASE: ToggleFavorite
// ============================================================================
// Mục đích:
//   - Đây là Usecase thuộc tầng Application của module "library_manga".
//   - Nhiệm vụ: Thay đổi trạng thái YÊU THÍCH của một manga.
//       + Nếu manga chưa có trong danh sách yêu thích → thêm vào favorites.
//       + Nếu manga đã yêu thích → xoá khỏi favorites.
//
// Khi nào được gọi:
//   - Khi user nhấn icon trái tim (favorite) trong MangaDetail.
//   - Khi user muốn thêm/xóa manga khỏi trang Favorite.
//   - Có thể dùng lại ở Home, Search hoặc bất kỳ module nào.
//
// Luồng hoạt động:
//   1) UI (hoặc BLoC) gọi ToggleFavorite(...) và truyền:
//        - mangaId
//        - title
//        - coverImageUrl
//   2) Usecase forward dữ liệu xuống LibraryRepository.toggleFavorite()
//   3) Repository quyết định:
//        - Nếu tồn tại trong Hive → xoá
//        - Nếu không tồn tại → thêm
//   4) Repository emit dữ liệu mới nếu cần (optional).
//
// Tại sao cần Usecase riêng?
//   - Giảm phụ thuộc UI → Repository.
//   - Theo kiến trúc Clean Architecture, Usecase là nơi quy định NGHIỆP VỤ.
//   - Dễ test (mock repo), dễ thay đổi cách lưu mà UI không phải sửa.
//
// Lưu ý:
//   - Không trả về boolean (được thêm hay được xoá). Nếu UI muốn biết,
//     có thể gọi thêm GetFavorites() sau khi toggle để cập nhật state.
//   - Nếu sau này cần analytics (ghi log số lần user favorite),
//     sẽ thêm logic vào Usecase mà UI không bị ảnh hưởng.
//
// ============================================================================

import '../../domain/repositories/library_repository.dart';

class ToggleFavorite {
  final LibraryRepository _repo;
  const ToggleFavorite(this._repo);

  Future<void> call({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  }) {
    // Forward xuống Repository xử lý logic thêm/xóa yêu thích.
    return _repo.toggleFavorite(
      mangaId: mangaId,
      title: title,
      coverImageUrl: coverImageUrl,
    );
  }
}
