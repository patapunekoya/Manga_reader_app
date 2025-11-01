// lib/presentation/bloc/favorites_state.dart
part of 'favorites_bloc.dart';

enum FavoritesStatus {
  initial,
  loading,
  success,
  failure,
}

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteItem> favorites;
  final String? errorMessage;

  const FavoritesState({
    required this.status,
    required this.favorites,
    required this.errorMessage,
  });

  const FavoritesState.initial()
      : status = FavoritesStatus.initial,
        favorites = const [],
        errorMessage = null;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteItem>? favorites,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, errorMessage];
}
