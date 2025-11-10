// modules/catalog/lib/domain/repositories/catalog_repository.dart
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';

abstract class CatalogRepository {
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,
    required int offset,
    required int limit,
  });

  Future<Manga> getMangaDetail({required MangaId mangaId});

  /// languageFilter nullable: null = All languages (dùng fallback đa ngôn ngữ).
  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    LanguageCode? languageFilter, // <<< đổi thành nullable
    required int offset,
    required int limit,
  });
}
