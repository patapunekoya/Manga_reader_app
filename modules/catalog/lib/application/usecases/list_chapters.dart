// lib/application/usecases/list_chapters.dart
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/value_objects/manga_id.dart';
import '../../domain/value_objects/language_code.dart';

class ListChapters {
  final CatalogRepository _repo;
  const ListChapters(this._repo);

  Future<List<Chapter>> call({
    required MangaId mangaId,
    required bool ascending,
    required LanguageCode languageFilter,
    required int offset,
    required int limit,
  }) {
    return _repo.listChapters(
      mangaId: mangaId,
      ascending: ascending,
      languageFilter: languageFilter,
      offset: offset,
      limit: limit,
    );
  }
}
