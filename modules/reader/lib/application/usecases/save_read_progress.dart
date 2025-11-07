// modules/reader/lib/application/usecases/save_read_progress.dart
import 'package:library_manga/domain/repositories/library_repository.dart';

/// Facade để module reader gọi thẳng.
class SaveReadProgress {
  final LibraryRepository _repo;
  const SaveReadProgress(this._repo);

  Future<void> call({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  }) {
    return _repo.saveReadProgress(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverImageUrl: coverImageUrl,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
    );
  }
}
