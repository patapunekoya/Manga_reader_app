import 'package:hive_flutter/hive_flutter.dart';

/// ============================================================================
/// LibraryLocalDataSource
/// ============================================================================
/// DataSource tầng *infrastructure* dùng Hive để lưu trữ Local:
///   - Manga Favorites (yêu thích)
///   - Reading Progress (chương gần nhất theo từng manga)
///
/// Đây là lớp THẤP NHẤT trong module library:
///   ✅ RepositoryImpl sẽ gọi class này.
///   ❌ UI/BLoC KHÔNG được gọi trực tiếp.
///
/// Cơ chế:
///   - Dùng 2 Hive Box:
///       • favorites_box  -> lưu manga user thả tim.
///       • progress_box   -> lưu tiến trình đọc theo mangaId.
///   - Mỗi record lưu kiểu Map<String, dynamic>.
///
/// Lưu ý:
///   • Phải gọi `init()` trước khi dùng, thường đặt trong bootstrap.
///   • Nếu quên init, _ensureReady() sẽ quăng StateError ngay cho bạn nhớ đời.
///   • Box dùng key = mangaId (string), value = Map raw JSON tự build.
///   • Không dùng adapter tránh phức tạp, vì cấu trúc data khá đơn giản.
///
/// Phạm vi dùng:
///   - LibraryRepositoryImpl gọi để CRUD dữ liệu local.
///   - GetContinueReading, ToggleFavorite, SaveReadProgress…
///
/// Không xử lý domain logic ở đây, chỉ đọc/ghi raw dữ liệu.
/// ============================================================================

class LibraryLocalDataSource {
  static const favoritesBoxName = 'favorites_box';
  static const progressBoxName  = 'progress_box';

  late Box _favoritesBox;
  late Box _progressBox;
  bool _initialized = false;

  /// Gọi 1 lần duy nhất trong bootstrap:
  ///   await sl<LibraryLocalDataSource>().init();
  Future<void> init() async {
    _favoritesBox = await Hive.openBox(favoritesBoxName);
    _progressBox  = await Hive.openBox(progressBoxName);
    _initialized = true;
  }

  /// Chặn việc dùng data source trước khi init()
  void _ensureReady() {
    if (!_initialized) {
      throw StateError(
        'LibraryLocalDataSource used before init(). Hãy gọi init() trong bootstrap.',
      );
    }
  }

  // ===========================================================================
  // FAVORITES — CRUD từng item & lấy toàn bộ
  // Key = mangaId, Value = Map<String, dynamic>
  // ===========================================================================

  /// Lấy dict favorite theo mangaId
  Map<String, dynamic>? getFavoriteRaw(String mangaId) {
    _ensureReady();
    final raw = _favoritesBox.get(mangaId);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Lưu/ghi đè 1 favorite record
  Future<void> putFavoriteRaw(String mangaId, Map<String, dynamic> data) async {
    _ensureReady();
    await _favoritesBox.put(mangaId, data);
  }

  /// Xoá 1 manga khỏi favorites
  Future<void> deleteFavorite(String mangaId) async {
    _ensureReady();
    await _favoritesBox.delete(mangaId);
  }

  /// Lấy toàn bộ list favorites ở dạng raw Map
  List<Map<String, dynamic>> getAllFavoritesRaw() {
    _ensureReady();
    return _favoritesBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ===========================================================================
  // PROGRESS — tiến trình đọc theo mangaId
  // Key = mangaId, Value = Map<String, dynamic>
  // ===========================================================================

  /// Ghi progress mới cho 1 manga
  Future<void> putProgressByMangaId(String mangaId, Map<String, dynamic> data) async {
    _ensureReady();
    await _progressBox.put(mangaId, data);
  }

  /// Lấy progress của 1 manga (nếu có)
  Map<String, dynamic>? getProgressByMangaId(String mangaId) {
    _ensureReady();
    final raw = _progressBox.get(mangaId);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Lấy toàn bộ progress để sort & build Continue Reading list
  List<Map<String, dynamic>> getAllProgressRaw() {
    _ensureReady();
    return _progressBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Xoá toàn bộ lịch sử đọc
  Future<void> clearAllProgress() async {
    _ensureReady();
    await _progressBox.clear();
  }
}
