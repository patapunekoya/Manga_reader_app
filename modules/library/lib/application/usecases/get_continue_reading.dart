// modules/library_manga/lib/application/usecases/get_continue_reading.dart
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/library_repository.dart';

class GetContinueReading {
  final LibraryRepository _repo;
  const GetContinueReading(this._repo);

  Future<List<ReadingProgress>> call() {
    return _repo.getContinueReading();
  }
}
