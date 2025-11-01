// modules/catalog/lib/application/usecases/search_manga.dart
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/repositories/catalog_repository.dart';

class SearchManga {
  final CatalogRepository _repo;
  const SearchManga(this._repo);

  /// Search truyện theo text [query] + optional [genre].
  /// - query có thể rỗng nếu user chỉ lọc theo thể loại
  /// - genre có thể null => không lọc thể loại
  /// - offset/limit dùng cho phân trang
  Future<List<Manga>> call({
    required String query,
    String? genre,          // <-- thêm
    required int offset,
    required int limit,
  }) {
    return _repo.searchManga(
      query: query,
      genre: genre,         // <-- forward
      offset: offset,
      limit: limit,
    );
  }
}
