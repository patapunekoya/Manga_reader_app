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

// NEW: toggle favorite
class MangaDetailFavoriteToggled extends MangaDetailEvent {
  const MangaDetailFavoriteToggled();
}

// NEW: sync lại trạng thái favorite từ repo (nếu cần)
class MangaDetailRefreshFavorite extends MangaDetailEvent {
  const MangaDetailRefreshFavorite();
}
