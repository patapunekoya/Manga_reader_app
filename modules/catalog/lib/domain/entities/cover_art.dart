// lib/domain/entities/cover_art.dart
import 'package:equatable/equatable.dart';

/// CoverArt: thông tin ảnh bìa manga.
/// Ta tách riêng để rõ ràng, nhưng Manga entity sẽ giữ 1 coverArtUrl cho tiện.
class CoverArt extends Equatable {
  final String imageUrl; // full URL sẵn dùng cho UI

  const CoverArt({
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [imageUrl];
}
