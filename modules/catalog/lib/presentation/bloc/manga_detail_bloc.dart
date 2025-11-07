import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_manga_detail.dart';
import '../../application/usecases/list_chapters.dart';
import '../../domain/entities/manga.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/value_objects/manga_id.dart';
import '../../domain/value_objects/language_code.dart';

// Favorite usecases (từ module library_manga)
import 'package:library_manga/application/usecases/get_favorites.dart';
import 'package:library_manga/application/usecases/toggle_favorite.dart';
import 'package:library_manga/domain/entities/favorite_item.dart';

part 'manga_detail_event.dart';
part 'manga_detail_state.dart';

class MangaDetailBloc extends Bloc<MangaDetailEvent, MangaDetailState> {
  final GetMangaDetail _getMangaDetail;
  final ListChapters _listChapters;

  // NEW: favorite
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  static const pageSize = 50;

  MangaDetailBloc({
    required GetMangaDetail getMangaDetail,
    required ListChapters listChapters,
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
  })  : _getMangaDetail = getMangaDetail,
        _listChapters = listChapters,
        _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const MangaDetailState.initial()) {
    on<MangaDetailLoadRequested>(_onLoadRequested);
    on<MangaDetailToggleSort>(_onToggleSort);
    on<MangaDetailLoadMoreChapters>(_onLoadMoreChapters);
    on<MangaDetailFavoriteToggled>(_onFavoriteToggled);
    on<MangaDetailRefreshFavorite>(_onRefreshFavorite);
  }

  Future<void> _onLoadRequested(
    MangaDetailLoadRequested event,
    Emitter<MangaDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: MangaDetailStatus.loading,
      mangaId: event.mangaId,
    ));

    try {
      // fetch detail
      final manga = await _getMangaDetail(
        mangaId: MangaId(event.mangaId),
      );

      // fetch chapters (ASC mặc định như yêu cầu trước)
      final chapters = await _listChapters(
        mangaId: MangaId(event.mangaId),
        ascending: state.ascending,
        languageFilter: const LanguageCode('en'),
        offset: 0,
        limit: pageSize,
      );

      // favorite state
      final favs = await _getFavorites();
      final isFav = favs.any((f) => f.id.value == event.mangaId);
      final patched = manga.copyWith(isFavorite: isFav);

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        manga: patched,
        chapters: chapters,
        hasMoreChapters: chapters.length == pageSize,
        chapterOffset: chapters.length,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MangaDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleSort(
    MangaDetailToggleSort event,
    Emitter<MangaDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: MangaDetailStatus.loadingChapters,
      ascending: !state.ascending,
      chapters: const [],
      hasMoreChapters: true,
      chapterOffset: 0,
    ));

    try {
      final newChapters = await _listChapters(
        mangaId: MangaId(state.mangaId),
        ascending: !state.ascending,
        languageFilter: const LanguageCode('en'),
        offset: 0,
        limit: pageSize,
      );

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        chapters: newChapters,
        hasMoreChapters: newChapters.length == pageSize,
        chapterOffset: newChapters.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MangaDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreChapters(
    MangaDetailLoadMoreChapters event,
    Emitter<MangaDetailState> emit,
  ) async {
    if (!state.hasMoreChapters ||
        state.status == MangaDetailStatus.loadingMoreChapters) {
      return;
    }

    emit(state.copyWith(status: MangaDetailStatus.loadingMoreChapters));

    try {
      final more = await _listChapters(
        mangaId: MangaId(state.mangaId),
        ascending: state.ascending,
        languageFilter: const LanguageCode('en'),
        offset: state.chapterOffset,
        limit: pageSize,
      );

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        chapters: [...state.chapters, ...more],
        hasMoreChapters: more.length == pageSize,
        chapterOffset: state.chapterOffset + more.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MangaDetailStatus.failure,
        hasMoreChapters: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFavoriteToggled(
    MangaDetailFavoriteToggled event,
    Emitter<MangaDetailState> emit,
  ) async {
    // Optimistic UI: flip ngay
    final current = state.manga;
    if (current == null) return;

    final flipped = current.copyWith(isFavorite: !current.isFavorite);
    emit(state.copyWith(manga: flipped));

    try {
      await _toggleFavorite(
        mangaId: state.mangaId,
        title: current.title,
        coverImageUrl: current.coverImageUrl,
      );
      // sau khi toggle xong, có thể refresh Favorites tab ở nơi khác bằng bloc riêng
    } catch (e) {
      // nếu fail thì revert
      emit(state.copyWith(manga: current));
    }
  }

  Future<void> _onRefreshFavorite(
    MangaDetailRefreshFavorite event,
    Emitter<MangaDetailState> emit,
  ) async {
    final current = state.manga;
    if (current == null) return;

    try {
      final favs = await _getFavorites();
      final isFav = favs.any((f) => f.id.value == state.mangaId);
      emit(state.copyWith(manga: current.copyWith(isFavorite: isFav)));
    } catch (_) {
      // im lặng, khỏi quấy UI
    }
  }
}
