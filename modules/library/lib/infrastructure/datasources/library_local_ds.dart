// modules/library/lib/infrastructure/datasources/library_local_ds.dart
import 'package:hive_flutter/hive_flutter.dart';

/// Box:
/// - favorites_box[mangaId] -> {...}
/// - progress_box[mangaId]  -> {
///     "mangaId": "...",
///     "mangaTitle": "...",
///     "coverImageUrl": "...",
///     "lastChapterId": "...",
///     "lastChapterNumber": "...",
///     "savedAt": epochMs
///   }
class LibraryLocalDataSource {
  static const favoritesBoxName = 'favorites_box';
  static const progressBoxName  = 'progress_box';

  late Box _favoritesBox;
  late Box _progressBox;
  bool _initialized = false;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox(favoritesBoxName);
    _progressBox  = await Hive.openBox(progressBoxName);
    _initialized  = true;
  }

  void _ensureReady() {
    if (!_initialized) {
      throw StateError(
        'LibraryLocalDataSource used before init(). '
        'Call await sl<LibraryLocalDataSource>().init() in bootstrap().',
      );
    }
  }

  // ===== FAVORITES =====
  Map<String, dynamic>? getFavoriteRaw(String mangaId) {
    _ensureReady();
    final raw = _favoritesBox.get(mangaId);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> putFavoriteRaw(String mangaId, Map<String, dynamic> data) async {
    _ensureReady();
    await _favoritesBox.put(mangaId, data);
  }

  Future<void> deleteFavorite(String mangaId) async {
    _ensureReady();
    await _favoritesBox.delete(mangaId);
  }

  List<Map<String, dynamic>> getAllFavoritesRaw() {
    _ensureReady();
    return _favoritesBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ===== PROGRESS (key = mangaId) =====
  Future<void> putProgressByMangaId(String mangaId, Map<String, dynamic> data) async {
    _ensureReady();
    await _progressBox.put(mangaId, data);
  }

  Map<String, dynamic>? getProgressByMangaId(String mangaId) {
    _ensureReady();
    final raw = _progressBox.get(mangaId);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  List<Map<String, dynamic>> getAllProgressRaw() {
    _ensureReady();
    return _progressBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
