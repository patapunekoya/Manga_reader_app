part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

class FavoritesRefreshRequested extends FavoritesEvent {
  const FavoritesRefreshRequested();
}

class FavoritesToggleRequested extends FavoritesEvent {
  final String mangaId;
  final String title;
  final String? coverImageUrl;
  const FavoritesToggleRequested({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
  });

  @override
  List<Object?> get props => [mangaId, title, coverImageUrl];
}
