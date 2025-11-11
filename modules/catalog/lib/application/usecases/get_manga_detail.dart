// lib/application/usecases/get_manga_detail.dart

import '../../domain/entities/manga.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/value_objects/manga_id.dart';

/// ======================================================================
/// UseCase: GetMangaDetail
/// Mục đích:
///   - Lấy thông tin chi tiết của một Manga (title, desc, cover, tags, …).
///   - Tách riêng logic truy xuất ra khỏi UI và Bloc.
///
/// Vai trò trong kiến trúc:
///   - Đây là tầng Application (UseCase) nên KHÔNG chứa logic UI.
///   - Chỉ nhận input thuần (MangaId) và trả về Entity (Manga).
///   - Giao tiếp 1 chiều với Domain Repository.
///
/// Dòng chảy:
///   UI → Bloc → GetMangaDetail → CatalogRepository.getMangaDetail → Manga
///
/// Lưu ý:
///   - Không bắt lỗi trong UseCase; lỗi được propagate lên Bloc để xử lý.
///   - Trả về Entity đã được mapping hoàn chỉnh (từ repository impl).
/// ======================================================================
class GetMangaDetail {
  final CatalogRepository _repo;

  /// Inject Repository (định nghĩa trong domain, cài đặt trong infrastructure)
  const GetMangaDetail(this._repo);

  /// Thực thi use case:
  /// - Input: MangaId (Value Object đảm bảo hợp lệ)
  /// - Output: Future<Manga> (Entity thuần)
  Future<Manga> call({required MangaId mangaId}) {
    return _repo.getMangaDetail(mangaId: mangaId);
  }
}
