// lib/application/usecases/toggle_favorite.dart
import '../../domain/repositories/library_repository.dart';

class ToggleFavorite {
  final LibraryRepository _repo;
  const ToggleFavorite(this._repo);

  Future<void> call({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  }) {
    return _repo.toggleFavorite(
      mangaId: mangaId,
      title: title,
      coverImageUrl: coverImageUrl,
    );
  }
}
