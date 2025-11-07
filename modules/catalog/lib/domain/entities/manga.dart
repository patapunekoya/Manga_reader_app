// lib/domain/entities/manga.dart
import 'package:equatable/equatable.dart';
import '../value_objects/manga_id.dart';

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

  /// Thời điểm cập nhật gần nhất (từ MangaDex: updatedAt/publishAt/readableAt... tùy mapper).
  final DateTime? updatedAt;

  /// Nếu lấy được (bayesian rating) thì gán, không thì null.
  final double? rating;

  /// Local state (favorite) – có thể map ở repository khác/hive.
  final bool isFavorite;

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
  });

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
      ];
}
