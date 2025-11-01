// lib/domain/value_objects/manga_id.dart
import 'package:equatable/equatable.dart';

/// MangaId: value object đại diện cho id manga MangaDex.
/// Dùng object thay vì String trần cho code đỡ lẫn lộn.
class MangaId extends Equatable {
  final String value;
  const MangaId(this.value);

  @override
  List<Object?> get props => [value];
}
