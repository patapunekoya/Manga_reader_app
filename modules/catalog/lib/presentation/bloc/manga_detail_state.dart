// lib/presentation/bloc/manga_detail_state.dart
part of 'manga_detail_bloc.dart';

enum MangaDetailStatus {
  initial,
  loading,
  success,
  failure,
  loadingChapters,
  loadingMoreChapters,
}

class MangaDetailState extends Equatable {
  final MangaDetailStatus status;

  final String mangaId;
  final Manga? manga;

  final List<Chapter> chapters;
  final bool ascending; // true = asc, false = desc
  final bool hasMoreChapters;
  final int chapterOffset;

  final String? errorMessage;

  const MangaDetailState({
    required this.status,
    required this.mangaId,
    required this.manga,
    required this.chapters,
    required this.ascending,
    required this.hasMoreChapters,
    required this.chapterOffset,
    required this.errorMessage,
  });

  const MangaDetailState.initial()
      : status = MangaDetailStatus.initial,
        mangaId = '',
        manga = null,
        chapters = const [],
        ascending = false, // default desc (chương mới nhất lên đầu)
        hasMoreChapters = true,
        chapterOffset = 0,
        errorMessage = null;

  MangaDetailState copyWith({
    MangaDetailStatus? status,
    String? mangaId,
    Manga? manga,
    List<Chapter>? chapters,
    bool? ascending,
    bool? hasMoreChapters,
    int? chapterOffset,
    String? errorMessage,
  }) {
    return MangaDetailState(
      status: status ?? this.status,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      ascending: ascending ?? this.ascending,
      hasMoreChapters: hasMoreChapters ?? this.hasMoreChapters,
      chapterOffset: chapterOffset ?? this.chapterOffset,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mangaId,
        manga,
        chapters,
        ascending,
        hasMoreChapters,
        chapterOffset,
        errorMessage,
      ];
}
