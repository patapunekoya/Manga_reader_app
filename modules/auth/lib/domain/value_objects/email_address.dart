// modules/auth/lib/domain/value_objects/email_address.dart
import 'package:equatable/equatable.dart';

class EmailAddress extends Equatable {
  final String value;

  const EmailAddress._(this.value);

  // Factory để tạo (và có thể thêm logic validate email ở đây)
  factory EmailAddress(String input) {
    // Đây là nơi bạn thêm logic validation regex hoặc format
    if (input.isEmpty || !input.contains('@')) {
      throw const FormatException('Email không hợp lệ.');
    }
    return EmailAddress._(input);
  }

  @override
  List<Object?> get props => [value];
}