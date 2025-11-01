// lib/application/usecases/get_favorites.dart
import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/library_repository.dart';

class GetFavorites {
  final LibraryRepository _repo;
  const GetFavorites(this._repo);

  Future<List<FavoriteItem>> call() {
    return _repo.getFavorites();
  }
}
