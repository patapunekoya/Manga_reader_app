// modules/catalog/lib/application/usecases/list_chapters.dart

import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/entities/chapter.dart';

/// ======================================================================
/// UseCase: ListChapters
///
/// Mục đích:
///   - Lấy danh sách Chapter của một Manga.
///   - Áp dụng sắp xếp (ascending/descending).
///   - Áp dụng lọc ngôn ngữ (languageFilter) nếu có.
///   - Hỗ trợ phân trang (offset + limit).
///
/// Vị trí kiến trúc:
///   - Tầng Application (UseCase) → chỉ điều phối chứ không chứa logic UI.
///   - Gọi đúng interface CatalogRepository ở domain.
///   - RepositoryImpl ở infrastructure sẽ xử lý:
///       • Gọi API MangaDex /manga/{id}/feed
///       • Mapping JSON → Chapter entity
///       • Xử lý fallback cho ngôn ngữ (nếu languageFilter = null)
///
/// Dòng chảy dữ liệu:
///   Bloc → ListChapters → Repository.listChapters → List<Chapter>
///   UI chỉ dùng entity thuần, không thấy DTO hay JSON.
///
/// Ghi chú:
///   - languageFilter là nullable:
///       null → lấy tất cả ngôn ngữ hoặc fallback theo strategy của repo.
///   - UseCase không try/catch: lỗi propagate lên Bloc để xử lý.
/// ======================================================================
class ListChapters {
  final CatalogRepository _repo;

  /// Inject repository theo interface Domain.
  const ListChapters(this._repo);

  /// Thực thi use case.
  /// - [mangaId]: MangaId (Value Object đảm bảo hợp lệ)
  /// - [ascending]: true = sắp tăng, false = giảm
  /// - [languageFilter]: lọc theo mã ngôn ngữ ISO (vi, en…), nullable
  /// - [offset]/[limit]: phân trang
  Future<List<Chapter>> call({
    required MangaId mangaId,
    required bool ascending,
    LanguageCode? languageFilter, // <<< nullable
    required int offset,
    required int limit,
  }) {
    return _repo.listChapters(
      mangaId: mangaId,
      ascending: ascending,
      languageFilter: languageFilter, // pass-through
      offset: offset,
      limit: limit,
    );
  }
}
