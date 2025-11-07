part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteItem> items;
  final String? errorMessage;

  const FavoritesState({
    required this.status,
    required this.items,
    required this.errorMessage,
  });

  const FavoritesState.initial()
      : status = FavoritesStatus.initial,
        items = const [],
        errorMessage = null;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteItem>? items,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
