// lib/domain/value_objects/language_code.dart

import 'package:equatable/equatable.dart';

/// ======================================================================
/// Value Object: LanguageCode
///
/// Mục đích:
///   - Đại diện cho mã ngôn ngữ (ISO code) như "en", "jp", "vi".
///   - Dùng để filter chapter theo ngôn ngữ ở màn chi tiết/reader.
///   - Tránh dùng string raw trong domain → tăng type-safety.
///
/// Đặc điểm Value Object:
///   - Bất biến (immutable).
///   - So sánh theo giá trị (Equatable).
///   - Không chứa logic parse hay validate phức tạp.
///   - Mọi xử lý liên quan tới mapping (vd: API trả ["en","vi"]) được thực hiện
///     ở tầng DTO / repository trước khi đưa vào VO.
///
/// Lợi ích:
///   - Rõ ràng ý nghĩa dữ liệu: "đây là language code", không phải arbitrary string.
///   - Giảm rủi ro truyền nhầm string vào nơi không đúng.
///
/// Ghi chú:
///   - Có thể mở rộng thêm preset: LanguageCode.japanese, .vietnamese…
///   - `english` là constant tiện lợi dùng cho default filter.
///
/// ======================================================================
class LanguageCode extends Equatable {
  final String value;

  const LanguageCode(this.value);

  @override
  List<Object?> get props => [value];

  // Preset thường dùng (optional)
  static const english = LanguageCode('en');
}
