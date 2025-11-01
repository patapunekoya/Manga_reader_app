// lib/domain/entities/manga.dart
import 'package:equatable/equatable.dart';
import '../value_objects/manga_id.dart';

/// Manga: entity sạch dùng cho UI và logic.
/// Chứa những thứ cần show ở SearchView, MangaDetailView.
class Manga extends Equatable {
  final MangaId id;
  final String title;
  final String? description; // có thể null khi search
  final String status;       // ongoing/completed/...
  final List<String> tags;   // top genres
  final String? coverImageUrl;
  final String? authorName;
  final int? year;
  final double? rating;      // nếu lấy được bayesian rating
  final bool isFavorite;     // app local có thể map sau (for future)

  const Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tags,
    required this.coverImageUrl,
    required this.authorName,
    required this.year,
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
        rating,
        isFavorite,
      ];
}
