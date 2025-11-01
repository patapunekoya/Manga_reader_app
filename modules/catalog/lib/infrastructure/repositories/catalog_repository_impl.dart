// modules/catalog/lib/infrastructure/repositories/catalog_repository_impl.dart
import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';

import '../datasources/catalog_remote_ds.dart';
import '../datasources/catalog_local_ds.dart';
import '../dtos/manga_dto.dart';
import '../dtos/chapter_dto.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;

  CatalogRepositoryImpl(
    this._remote,
    this._local,
  );

  @override
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,           // <-- thêm tham số này để khớp interface
    required int offset,
    required int limit,
  }) async {
    // gọi remote
    final rawList = await _remote.searchMangaRaw(
      query: query,
      genre: genre,          // <-- forward genre xuống datasource
      offset: offset,
      limit: limit,
    );

    // map JSON -> domain Manga
    return rawList.map((raw) {
      final dto = MangaDto.fromMangaDexJson(raw);
      // TODO: check local favorites để gắn isFavorite=true nếu cần
      return dto.toDomain(isFavorite: false);
    }).toList();
  }

  @override
  Future<Manga> getMangaDetail({
    required MangaId mangaId,
  }) async {
    final raw = await _remote.getMangaDetailRaw(
      mangaId: mangaId.value,
    );

    if (raw == null) {
      throw Exception("Manga not found: ${mangaId.value}");
    }

    final dto = MangaDto.fromMangaDexJson(raw);
    // TODO: check local favorites
    return dto.toDomain(isFavorite: false);
  }

  @override
  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    required LanguageCode languageFilter,
    required int offset,
    required int limit,
  }) async {
    final rawList = await _remote.listChaptersRaw(
      mangaId: mangaId.value,
      ascending: ascending,
      language: languageFilter.value,
      offset: offset,
      limit: limit,
    );

    return rawList.map((raw) {
      final dto = ChapterDto.fromMangaDexJson(raw);
      return dto.toDomain(mangaIdOverride: mangaId.value);
    }).toList();
  }
}
