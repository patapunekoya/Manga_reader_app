// lib/domain/value_objects/favorite_id.dart
import 'package:equatable/equatable.dart';

/// FavoriteId: dùng mangaId luôn.
/// Tách ra kiểu VO cho rõ.
class FavoriteId extends Equatable {
  final String value;
  const FavoriteId(this.value);

  @override
  List<Object?> get props => [value];
}
