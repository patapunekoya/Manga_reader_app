// lib/application/usecases/save_read_progress.dart
import '../../domain/repositories/library_repository.dart';

class SaveReadProgress {
  final LibraryRepository _repo;
  const SaveReadProgress(this._repo);

  Future<void> call({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
    required int pageIndex,
  }) {
    return _repo.saveReadProgress(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverImageUrl: coverImageUrl,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      pageIndex: pageIndex,
    );
  }
}
