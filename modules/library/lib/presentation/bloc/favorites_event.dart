// lib/presentation/bloc/favorites_event.dart
part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
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
