// modules/catalog/lib/application/usecases/list_chapters.dart
import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/entities/chapter.dart';

class ListChapters {
  final CatalogRepository _repo;
  const ListChapters(this._repo);

  /// languageFilter nullable: null = All (repo sẽ dùng đa ngôn ngữ + fallback)
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
