// lib/application/usecases/report_image_error.dart
import '../../domain/repositories/reader_repository.dart';

/// ReportImageError:
/// một số app gửi metric khi ảnh fail. Ở đây ta cứ expose usecase.
/// MVP: repo_impl có thể log/print thôi.
class ReportImageError {
  final ReaderRepository _repo;
  const ReportImageError(this._repo);

  Future<void> call({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  }) {
    return _repo.reportImageError(
      chapterId: chapterId,
      pageIndex: pageIndex,
      imageUrl: imageUrl,
    );
  }
}
