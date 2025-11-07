import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Domain
import '../../domain/entities/favorite_item.dart';

// Usecases
import '../../application/usecases/get_favorites.dart';
import '../../application/usecases/toggle_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  FavoritesBloc({
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const FavoritesState.initial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<FavoritesRefreshRequested>(_onRefreshRequested);
    on<FavoritesToggleRequested>(_onToggleRequested);
  }

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
