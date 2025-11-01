// lib/presentation/bloc/manga_detail_event.dart
part of 'manga_detail_bloc.dart';

@immutable
abstract class MangaDetailEvent extends Equatable {
  const MangaDetailEvent();

  @override
  List<Object?> get props => [];
}

class MangaDetailLoadRequested extends MangaDetailEvent {
  final String mangaId;
  const MangaDetailLoadRequested(this.mangaId);

  @override
  List<Object?> get props => [mangaId];
}

class MangaDetailToggleSort extends MangaDetailEvent {
  const MangaDetailToggleSort();
}

class MangaDetailLoadMoreChapters extends MangaDetailEvent {
  const MangaDetailLoadMoreChapters();
}
