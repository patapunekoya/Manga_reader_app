// modules/auth/lib/domain/value_objects/password.dart
import 'package:equatable/equatable.dart';

class Password extends Equatable {
  final String value;

  const Password._(this.value);

  // Factory để tạo (và có thể thêm logic validate độ mạnh mật khẩu)
  factory Password(String input) {
    if (input.length < 6) {
      throw const FormatException('Mật khẩu phải có ít nhất 6 ký tự.');
    }
    return Password._(input);
  }

  @override
  List<Object?> get props => [value];
}