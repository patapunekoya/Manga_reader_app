// modules/catalog/lib/domain/repositories/catalog_repository.dart

import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';

/// ======================================================================
/// Domain Repository: CatalogRepository
///
/// Mục đích:
///   - Định nghĩa hợp đồng (interface) cho tầng Application/UseCase.
///   - Tách biệt domain khỏi implementation thật (API MangaDex, cache, Hive, …).
///   - UI/BLoC chỉ giao tiếp qua repository interface, không phụ thuộc hạ tầng.
///
/// Vị trí trong kiến trúc:
///   - Thuộc tầng Domain.
///   - Không chứa logic gọi API, parse JSON, hay xử lý lỗi.
///   - Repository implementation nằm ở infrastructure (datasource + DTO).
///
/// Trách nhiệm chính:
///   • Search manga (từ khóa + thể loại + phân trang)
///   • Lấy chi tiết manga
///   • Lấy danh sách chapters (sắp xếp, lọc ngôn ngữ, phân trang)
///
/// Quy ước:
///   - `genre` nullable → không lọc.
///   - `languageFilter` nullable → repo phải xử lý “tất cả ngôn ngữ”
///       hoặc fallback theo chiến lược riêng.
///   - Entity trả về luôn là dữ liệu sạch, đã mapping (Manga, Chapter).
///
/// Dòng chảy ví dụ:
///   UI → Bloc → UseCase → CatalogRepository → Impl → RemoteDS/LocalDS → DTO → Entity
///
/// ======================================================================
abstract class CatalogRepository {
  /// Search manga theo:
  /// - [query]  : từ khóa (có thể rỗng)
  /// - [genre]  : lọc theo tag/thể loại (nullable)
  /// - offset/limit: phân trang
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,
    required int offset,
    required int limit,
  });

  /// Lấy chi tiết đầy đủ của 1 manga bằng MangaId.
  Future<Manga> getMangaDetail({required MangaId mangaId});

  /// Lấy danh sách chapter theo mangaId:
  /// - [ascending]      : sắp tăng hay giảm
  /// - [languageFilter] : nullable → tất cả ngôn ngữ (repo fallback)
  /// - [offset]/[limit] : phân trang
  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    LanguageCode? languageFilter, // <<< nullable cho filter ngôn ngữ
    required int offset,
    required int limit,
  });
}
