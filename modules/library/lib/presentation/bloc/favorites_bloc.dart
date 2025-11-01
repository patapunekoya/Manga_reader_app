// lib/presentation/bloc/favorites_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_favorites.dart';
import '../../application/usecases/toggle_favorite.dart';
import '../../domain/entities/favorite_item.dart';

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
    on<FavoritesToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final list = await _getFavorites();
      emit(state.copyWith(
        status: FavoritesStatus.success,
        favorites: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    // user bấm tim ♥ trong UI -> toggle -> sau đó reload list
    await _toggleFavorite(
      mangaId: event.mangaId,
      title: event.title,
      coverImageUrl: event.coverImageUrl,
    );

    // reload
    final list = await _getFavorites();
    emit(state.copyWith(
      status: FavoritesStatus.success,
      favorites: list,
    ));
  }
}
