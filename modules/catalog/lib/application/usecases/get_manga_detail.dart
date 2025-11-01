// lib/application/usecases/get_manga_detail.dart
import '../../domain/entities/manga.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/value_objects/manga_id.dart';

class GetMangaDetail {
  final CatalogRepository _repo;
  const GetMangaDetail(this._repo);

  Future<Manga> call({required MangaId mangaId}) {
    return _repo.getMangaDetail(mangaId: mangaId);
  }
}
