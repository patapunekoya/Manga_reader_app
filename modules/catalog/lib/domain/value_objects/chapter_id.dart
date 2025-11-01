// lib/domain/value_objects/chapter_id.dart
import 'package:equatable/equatable.dart';

/// ChapterId: id chapter trong MangaDex.
class ChapterId extends Equatable {
  final String value;
  const ChapterId(this.value);

  @override
  List<Object?> get props => [value];
}
