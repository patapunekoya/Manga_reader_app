// lib/domain/value_objects/language_code.dart
import 'package:equatable/equatable.dart';

/// LanguageCode: ví dụ "en", "jp", "vi".
/// Tùy app ông có muốn lọc chapter theo language nào.
class LanguageCode extends Equatable {
  final String value;
  const LanguageCode(this.value);

  @override
  List<Object?> get props => [value];

  static const english = LanguageCode('en');
}
