// lib/application/usecases/get_favorites.dart
//
// ============================================================================
// USECASE: GetFavorites
// ============================================================================
// Nhiệm vụ:
//   - Đây là Usecase thuộc tầng Application (Clean Architecture).
//   - Dùng để lấy danh sách manga mà người dùng đã đánh dấu "Yêu thích"
//     từ Local Storage (Hive).
//
// Tại sao tách làm Usecase:
//   - Giúp UI / Bloc không cần biết datasource nằm ở đâu (local/network).
//   - Dễ thay đổi nguồn dữ liệu sau này (ví dụ Cloud Sync).
//   - Có thể mock trong unit test để test logic HomeBloc hoặc FavoritesBloc.
//
// Flow xử lý:
//   1) Bloc / ViewModel gọi GetFavorites()
//   2) Usecase gọi xuống Repository: _repo.getFavorites()
//   3) Repository lấy list FavoriteItem từ Hive Local
//   4) Trả về List<FavoriteItem> để UI render.
//
// Vai trò trong module library_manga:
//   - Dùng trong màn "Favorites" (Danh sách truyện yêu thích).
//   - Dùng ở Home nếu cần hiển thị badge hoặc quick summary.
//
// Thiết kế chuẩn:
//   - Usecase này đúng chuẩn: chỉ thực hiện đúng 1 nhiệm vụ duy nhất.
//   - Không xử lý UI, không xử lý parse JSON, không xử lý logic lưu trữ.
//   - Chỉ đóng vai trò "cầu nối" giữa Bloc và Repository.
// ============================================================================

import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/library_repository.dart';

class GetFavorites {
  final LibraryRepository _repo;

  const GetFavorites(this._repo);

  Future<List<FavoriteItem>> call() {
    // chuyển nhiệm vụ xuống Repository để lấy dữ liệu từ Hive
    return _repo.getFavorites();
  }
}
