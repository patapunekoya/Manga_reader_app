// lib/domain/value_objects/manga_id.dart

import 'package:equatable/equatable.dart';

/// ======================================================================
/// Value Object: MangaId
///
/// Mục đích:
///   - Đại diện ID duy nhất của một Manga trên MangaDex.
///   - Dùng object thay vì String trần để tránh nhầm lẫn với chapterId,
///     authorId, hay các string khác trong code.
///
/// Vai trò trong Domain:
///   - Tăng tính type-safe trong kiến trúc DDD.
///   - Đảm bảo mỗi nơi thực thi biết rõ kiểu dữ liệu mình thao tác.
///   - UI/Bloc/UseCase không đụng JSON/String raw trực tiếp.
///
/// Đặc điểm VO:
///   - Bất biến (immutable).
///   - So sánh theo giá trị nhờ Equatable.
///   - Không parse JSON. DTO layer chịu trách nhiệm tạo MangaId(value).
///
/// Tình huống sử dụng điển hình:
///   - GetMangaDetail(mangaId: MangaId("..."))
///   - ListChapters(mangaId: MangaId("..."))
///   - Manga entity luôn chứa MangaId thay vì String.
///
/// ======================================================================
class MangaId extends Equatable {
  final String value;

  const MangaId(this.value);

  @override
  List<Object?> get props => [value];
}
