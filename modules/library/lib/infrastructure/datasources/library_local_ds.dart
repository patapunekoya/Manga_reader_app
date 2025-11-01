// lib/infrastructure/datasources/library_local_ds.dart
import 'package:hive_flutter/hive_flutter.dart';

/// LibraryLocalDataSource:
/// Chịu trách nhiệm đọc/ghi Hive.
/// - favorites_box: lưu manga yêu thích
/// - progress_box: lưu tiến trình đọc
///
/// Cấu trúc favorites_box[mangaId]:
/// {
///   "mangaId": "...",
///   "title": "...",
///   "coverImageUrl": "...",
///   "addedAt": epochMs,
///   "updatedAt": epochMs
/// }
///
/// Cấu trúc progress_box[chapterId]:
/// {
///   "chapterId": "...",
///   "mangaId": "...",
///   "mangaTitle": "...",
///   "coverImageUrl": "...",
///   "chapterNumber": "...",
///   "pageIndex": 12,
///   "savedAt": epochMs
/// }

class LibraryLocalDataSource {
  static const favoritesBoxName = 'favorites_box';
  static const progressBoxName = 'progress_box';

  late Box _favoritesBox;
  late Box _progressBox;

  bool _initialized = false;

  Future<void> init() async {
    // mở Hive box nếu chưa mở
    _favoritesBox = await Hive.openBox(favoritesBoxName);
    _progressBox = await Hive.openBox(progressBoxName);
    _initialized = true;
  }

  void _ensureReady() {
    if (!_initialized) {
      // tại sao cần cái này?
      // vì nếu ai quên gọi init() trong bootstrap thì chúng ta báo lỗi rõ ràng,
      // thay vì nổ LateInitializationError lung tung ở runtime.
      throw StateError(
        'LibraryLocalDataSource was used before init(). '
        'Hãy gọi await sl<LibraryLocalDataSource>().init() trong bootstrap() trước khi dùng.',
      );
    }
  }

  // FAVORITES --------------------------------

  Map<String, dynamic>? getFavoriteRaw(String mangaId) {
    _ensureReady();
    final raw = _favoritesBox.get(mangaId);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
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

  // PROGRESS ---------------------------------

  Future<void> putProgressRaw(String chapterId, Map<String, dynamic> data) async {
    _ensureReady();
    await _progressBox.put(chapterId, data);
  }

  List<Map<String, dynamic>> getAllProgressRaw() {
    _ensureReady();
    return _progressBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
