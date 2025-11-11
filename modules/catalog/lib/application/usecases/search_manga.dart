// modules/catalog/lib/application/usecases/search_manga.dart

import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/repositories/catalog_repository.dart';

/// ======================================================================
/// UseCase: SearchManga
///
/// Mục đích:
///   - Tìm kiếm Manga theo từ khóa (query) và/hoặc thể loại (genre).
///   - Hỗ trợ phân trang với offset + limit.
///   - Tách logic gọi repo ra khỏi UI/BLoC.
///
/// Vị trí trong kiến trúc:
///   - Đây là tầng Application (UseCase): chỉ điều phối tham số, không chứa
///     logic UI, không chứa logic parse JSON.
///   - Gọi CatalogRepository (interface thuộc domain).
///   - RepositoryImpl sẽ xử lý:
///        • Gọi API MangaDex `/manga`
///        • Mapping JSON → Manga entity
///        • Áp dụng tag filter nếu có `genre`
///
/// Quy ước:
///   - `query` có thể rỗng → search theo tag/category.
///   - `genre` nullable → null = không lọc theo thể loại.
///   - Không try/catch tại UseCase → lỗi được propagate lên Bloc.
///   - UI và Bloc chỉ thao tác với List<Manga> (entity), không dính DTO.
///
/// Dòng chảy:
///   SearchView → SearchBloc → SearchManga → repo.searchManga → List<Manga>
/// ======================================================================
class SearchManga {
  final CatalogRepository _repo;

  /// Inject repository theo interface domain
  const SearchManga(this._repo);

  /// Thực thi use case.
  ///
  /// Params:
  ///   - [query]: chuỗi tìm kiếm. Có thể "" nếu user chỉ lọc theo thể loại.
  ///   - [genre]: tên thể loại (nullable). null = không lọc.
  ///   - [offset], [limit]: phân trang dữ liệu.
  Future<List<Manga>> call({
    required String query,
    String? genre,          // <-- optional filter thể loại
    required int offset,
    required int limit,
  }) {
    return _repo.searchManga(
      query: query,
      genre: genre,         // <-- forward trực tiếp xuống repo
      offset: offset,
      limit: limit,
    );
  }
}
