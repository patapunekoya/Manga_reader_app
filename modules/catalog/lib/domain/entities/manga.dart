// lib/domain/entities/manga.dart

import 'package:equatable/equatable.dart';
import '../value_objects/manga_id.dart';

/// ======================================================================
/// Entity: Manga
///
/// Mục đích:
///   - Đại diện 1 đầu truyện (manga) ở tầng Domain.
///   - Dùng trực tiếp bởi UI (SearchView, MangaDetailView, Home feed, …)
///     và BLoC. Hoàn toàn tách biệt khỏi DTO/JSON.
///
/// Đặc điểm kiến trúc:
///   - Chỉ chứa Value Objects + primitive đã chuẩn hóa.
///   - DTO ở infrastructure chịu trách nhiệm parse & mapping vào đây.
///   - Support so sánh theo giá trị (Equatable) để tối ưu rebuild.
///
/// Trường dữ liệu:
///   - [id]               : MangaId (VO) – định danh duy nhất.
///   - [title]            : Tiêu đề.
///   - [description]      : Mô tả ngắn, có thể null khi chỉ tra nhanh.
///   - [status]           : Trạng thái (ongoing/completed/hiatus…).
///   - [tags]             : Danh sách tag/thể loại đã chuẩn hóa.
///   - [coverImageUrl]    : URL ảnh bìa (nếu lấy được từ relationships cover_art).
///   - [authorName]       : Tác giả (nullable).
///   - [year]             : Năm phát hành (nullable).
///   - [updatedAt]        : Lần cập nhật gần nhất (nếu API có).
///   - [rating]           : Điểm bayesian/aggregate (nullable).
///   - [isFavorite]       : Trạng thái local (Hive/Repo khác quản lý).
///   - [availableLanguages]: Danh sách mã ngôn ngữ có chapter (vd: ["en","vi"]).
///
/// Ghi chú:
///   - `availableLanguages` lấy từ `attributes.availableTranslatedLanguage`
///     của MangaDex, dùng để filter chapter theo ngôn ngữ ở màn chi tiết/reader.
///   - `isFavorite` là state cục bộ, không đến từ API; repo/hạ tầng gán vào.
///
/// copyWith:
///   - Hỗ trợ tạo biến thể mới của entity khi cần cập nhật một vài trường
///     (ví dụ đổi isFavorite, cập nhật cover, …).
/// ======================================================================

/// Manga: entity sạch dùng cho UI và logic.
/// Dùng cho SearchView, MangaDetailView, Home feed, v.v.
class Manga extends Equatable {
  final MangaId id;
  final String title;
  final String? description; // có thể null khi search
  final String status;       // ongoing/completed/hiatus...
  final List<String> tags;   // top genres / tags
  final String? coverImageUrl;
  final String? authorName;
  final int? year;

  /// Thời điểm cập nhật gần nhất (nếu parse được từ MangaDex)
  final DateTime? updatedAt;

  /// Nếu lấy được (bayesian rating) thì gán, không thì null.
  final double? rating;

  /// Local state (favorite) – map ở repository khác/hive.
  final bool isFavorite;

  /// NEW: danh sách ngôn ngữ có chapter cho manga này (từ attributes.availableTranslatedLanguage)
  final List<String> availableLanguages;

  const Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tags,
    required this.coverImageUrl,
    required this.authorName,
    required this.year,
    required this.updatedAt,
    required this.rating,
    required this.isFavorite,
    required this.availableLanguages, // NEW
  });

  /// Tạo bản sao với một vài trường thay đổi.
  /// Không làm mutate; đảm bảo tính bất biến của entity.
  Manga copyWith({
    String? title,
    String? description,
    String? status,
    List<String>? tags,
    String? coverImageUrl,
    String? authorName,
    int? year,
    DateTime? updatedAt,
    double? rating,
    bool? isFavorite,
    List<String>? availableLanguages, // NEW
  }) {
    return Manga(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      authorName: authorName ?? this.authorName,
      year: year ?? this.year,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      availableLanguages: availableLanguages ?? this.availableLanguages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        tags,
        coverImageUrl,
        authorName,
        year,
        updatedAt,
        rating,
        isFavorite,
        availableLanguages, // NEW
      ];
}
