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

part 'manga_detail_event.dart';
part 'manga_detail_state.dart';

class MangaDetailBloc extends Bloc<MangaDetailEvent, MangaDetailState> {
  final GetMangaDetail _getMangaDetail;
  final ListChapters _listChapters;

  // favorite
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
    on<MangaDetailSelectLanguage>(_onSelectLanguage);
  }

  // Rút danh sách ngôn ngữ từ list chapter
  List<String> _extractLanguages(List<Chapter> chapters) {
    final set = <String>{};
    for (final c in chapters) {
      final lang = c.language?.trim();
      if (lang != null && lang.isNotEmpty) set.add(lang);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> _onLoadRequested(
    MangaDetailLoadRequested event,
    Emitter<MangaDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: MangaDetailStatus.loading,
      mangaId: event.mangaId,
      chapters: const [],
      hasMoreChapters: true,
      chapterOffset: 0,
      availableLanguages: const [],
      selectedLanguage: null, // mặc định All
    ));

    try {
      // 1) fetch detail
      final manga = await _getMangaDetail(mangaId: MangaId(event.mangaId));

      // 2) favorite state
      final favs = await _getFavorites();
      final isFav = favs.any((f) => f.id.value == event.mangaId);
      final patched = manga.copyWith(isFavorite: isFav);

      // 3) fetch chapters theo selectedLanguage hiện tại (null = All)
      final selectedLang = state.selectedLanguage;
      final chapters = await _listChapters(
        mangaId: MangaId(event.mangaId),
        ascending: state.ascending,
        // NOTE: ListChapters nên nhận LanguageCode? (nullable). Nếu chưa, sửa usecase.
        languageFilter: selectedLang == null ? null : LanguageCode(selectedLang),
        offset: 0,
        limit: pageSize,
      );

      final langs = _extractLanguages(chapters);

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        manga: patched,
        chapters: chapters,
        hasMoreChapters: chapters.length == pageSize,
        chapterOffset: chapters.length,
        availableLanguages: langs,
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
      final selectedLang = state.selectedLanguage;
      final newChapters = await _listChapters(
        mangaId: MangaId(state.mangaId),
        ascending: !state.ascending,
        languageFilter: selectedLang == null ? null : LanguageCode(selectedLang),
        offset: 0,
        limit: pageSize,
      );

      final langs = _extractLanguages(newChapters);

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        chapters: newChapters,
        hasMoreChapters: newChapters.length == pageSize,
        chapterOffset: newChapters.length,
        availableLanguages: langs,
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
      final selectedLang = state.selectedLanguage;
      final more = await _listChapters(
        mangaId: MangaId(state.mangaId),
        ascending: state.ascending,
        languageFilter: selectedLang == null ? null : LanguageCode(selectedLang),
        offset: state.chapterOffset,
        limit: pageSize,
      );

      final merged = [...state.chapters, ...more];
      final langs = _extractLanguages(merged);

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        chapters: merged,
        hasMoreChapters: more.length == pageSize,
        chapterOffset: state.chapterOffset + more.length,
        availableLanguages: langs,
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
    final current = state.manga;
    if (current == null) return;

    // Optimistic
    final flipped = current.copyWith(isFavorite: !current.isFavorite);
    emit(state.copyWith(manga: flipped));

    try {
      await _toggleFavorite(
        mangaId: state.mangaId,
        title: current.title,
        coverImageUrl: current.coverImageUrl,
      );
    } catch (e) {
      // revert nếu lỗi
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
      // im lặng
    }
  }

  /// Chọn ngôn ngữ -> reload chương từ đầu
  Future<void> _onSelectLanguage(
    MangaDetailSelectLanguage event,
    Emitter<MangaDetailState> emit,
  ) async {
    if (state.mangaId.isEmpty) return;

    emit(state.copyWith(
      status: MangaDetailStatus.loadingChapters,
      selectedLanguage: event.language, // null = All
      chapters: const [],
      hasMoreChapters: true,
      chapterOffset: 0,
    ));

    try {
      final chapters = await _listChapters(
        mangaId: MangaId(state.mangaId),
        ascending: state.ascending,
        languageFilter:
            event.language == null ? null : LanguageCode(event.language!),
        offset: 0,
        limit: pageSize,
      );

      final langs = _extractLanguages(chapters);

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        chapters: chapters,
        hasMoreChapters: chapters.length == pageSize,
        chapterOffset: chapters.length,
        availableLanguages: langs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MangaDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
