import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Domain
import '../../domain/entities/favorite_item.dart';

// Usecases
import '../../application/usecases/get_favorites.dart';
import '../../application/usecases/toggle_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

/// =============================================================================
/// FavoritesBloc
/// =============================================================================
/// Mục đích
/// - Quản lý danh sách manga yêu thích (Favorites) lưu local.
/// - Cung cấp 3 luồng chính:
///   1) Tải danh sách lần đầu (FavoritesLoadRequested)
///   2) Làm mới danh sách (FavoritesRefreshRequested)
///   3) Thêm/bỏ yêu thích với tối ưu "optimistic update"
///
/// Kiến trúc
/// - Bloc nhận Event và phát State (Equatable để so sánh mượt, tránh rebuild thừa).
/// - Data thực lấy qua Usecases:
///     * GetFavorites: đọc toàn bộ danh sách từ Repository (Hive).
///     * ToggleFavorite: thêm/xoá một mục yêu thích.
///
/// Trạng thái (FavoritesState)
/// - status: initial | loading | success | failure
/// - items: List<FavoriteItem> (đã map ra entity domain)
/// - errorMessage: lỗi gần nhất (nếu có)
///
/// Lưu ý triển khai
/// - Dùng optimistic removal khi toggle để UI phản hồi tức thời, rồi đồng bộ lại
///   bằng cách gọi GetFavorites lần nữa.
/// - Khi Refresh lỗi, không chuyển sang failure để UI không "giật", chỉ gắn
///   errorMessage nhẹ.
/// - Bloc này không tự init Hive. Phải đảm bảo LibraryLocalDataSource.init()
///   đã được gọi trong bootstrap trước khi dùng các usecase.
///
/// Tích hợp UI
/// - Lần mở màn hình Favorites: bắn FavoritesLoadRequested()
/// - Kéo để làm mới: bắn FavoritesRefreshRequested()
/// - Bấm icon tim: bắn FavoritesToggleRequested(mangaId, title, coverImageUrl)
///
/// Test gợi ý
/// - Giả lập repo trả list rỗng -> state.success với items=[]
/// - Giả lập lỗi GetFavorites -> state.failure
/// - Toggle: kiểm tra optimistic update có xoá tạm trên state rồi đồng bộ lại
/// =============================================================================
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  FavoritesBloc({
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const FavoritesState.initial()) {
    // Đăng ký handlers
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<FavoritesRefreshRequested>(_onRefreshRequested);
    on<FavoritesToggleRequested>(_onToggleRequested);
  }

  /// Handler: tải lần đầu
  /// Flow:
  /// - emit loading
  /// - gọi _getFavorites()
  /// - emit success (items) hoặc failure (errorMessage)
  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading, errorMessage: null));
    try {
      final list = await _getFavorites();
      emit(state.copyWith(status: FavoritesStatus.success, items: list));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handler: làm mới dữ liệu (pull-to-refresh)
  /// - Không chuyển sang failure nếu lỗi để tránh UI nhảy trạng thái thô.
  /// - Chỉ cập nhật errorMessage khi fail.
  Future<void> _onRefreshRequested(
    FavoritesRefreshRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final list = await _getFavorites();
      emit(state.copyWith(status: FavoritesStatus.success, items: list));
    } catch (e) {
      // không hạ trạng thái về failure để UI không giật
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Handler: toggle favorite
  /// Chiến lược "Optimistic UI":
  /// - Nếu item đang có trong danh sách, xoá tạm để người dùng thấy phản hồi tức thì.
  /// - Gọi _toggleFavorite() để ghi thật.
  /// - Sau đó **luôn** đồng bộ lại với nguồn thật (_getFavorites) để bảo đảm nhất quán.
  /// - Nếu có lỗi, vẫn đồng bộ lại và kèm errorMessage.
  Future<void> _onToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    // Optimistic: nếu đang có trong danh sách thì remove tạm thời cho mượt
    final cur = List<FavoriteItem>.from(state.items);
    final idx = cur.indexWhere((x) => x.id.value == event.mangaId);
    if (idx >= 0) {
      cur.removeAt(idx);
      emit(state.copyWith(items: cur));
    }

    try {
      await _toggleFavorite(
        mangaId: event.mangaId,
        title: event.title,
        coverImageUrl: event.coverImageUrl,
      );
      // Đồng bộ lại từ nguồn thật
      final latest = await _getFavorites();
      emit(state.copyWith(status: FavoritesStatus.success, items: latest));
    } catch (e) {
      // Nếu fail thì reload để khớp với storage
      final latest = await _getFavorites();
      emit(state.copyWith(
        status: FavoritesStatus.success,
        items: latest,
        errorMessage: e.toString(),
      ));
    }
  }
}
