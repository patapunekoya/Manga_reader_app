// lib/domain/value_objects/at_home_url.dart
import 'package:equatable/equatable.dart';

/// AtHomeUrl bundle thông tin từ endpoint /at-home/server/{chapterId}.
/// Dùng để build URL ảnh.
/// baseUrl + /data/{hash}/{filename}
class AtHomeUrl extends Equatable {
  final String baseUrl;
  final String hash;

  const AtHomeUrl({
    required this.baseUrl,
    required this.hash,
  });

  /// build link đầy đủ cho 1 fileName
  String buildPageUrl(String fileName) {
    // full quality
    return "$baseUrl/data/$hash/$fileName";
  }

  /// Nếu muốn data-saver (chất lượng thấp hơn), dùng:
  /// "$baseUrl/data-saver/$hash/$fileName"
  @override
  List<Object?> get props => [baseUrl, hash];
}
