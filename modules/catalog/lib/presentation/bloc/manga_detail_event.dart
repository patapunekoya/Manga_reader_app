part of 'manga_detail_bloc.dart';

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

class MangaDetailFavoriteToggled extends MangaDetailEvent {
  const MangaDetailFavoriteToggled();
}

class MangaDetailRefreshFavorite extends MangaDetailEvent {
  const MangaDetailRefreshFavorite();
}

/// Chọn ngôn ngữ; null = All
class MangaDetailSelectLanguage extends MangaDetailEvent {
  final String? language;
  const MangaDetailSelectLanguage(this.language);

  @override
  List<Object?> get props => [language];
}
