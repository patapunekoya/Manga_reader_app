// modules/catalog/lib/domain/repositories/catalog_repository.dart
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';

abstract class CatalogRepository {
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,        // <-- thêm dòng này
    required int offset,
    required int limit,
  });

  Future<Manga> getMangaDetail({
    required MangaId mangaId,
  });

  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    required LanguageCode languageFilter,
    required int offset,
    required int limit,
  });
}
