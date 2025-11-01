// lib/presentation/bloc/manga_detail_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_manga_detail.dart';
import '../../application/usecases/list_chapters.dart';
import '../../domain/entities/manga.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/value_objects/manga_id.dart';
import '../../domain/value_objects/language_code.dart';

part 'manga_detail_event.dart';
part 'manga_detail_state.dart';

class MangaDetailBloc extends Bloc<MangaDetailEvent, MangaDetailState> {
  final GetMangaDetail _getMangaDetail;
  final ListChapters _listChapters;

  static const pageSize = 50; // chapter page size

  MangaDetailBloc({
    required GetMangaDetail getMangaDetail,
    required ListChapters listChapters,
  })  : _getMangaDetail = getMangaDetail,
        _listChapters = listChapters,
        super(const MangaDetailState.initial()) {
    on<MangaDetailLoadRequested>(_onLoadRequested);
    on<MangaDetailToggleSort>(_onToggleSort);
    on<MangaDetailLoadMoreChapters>(_onLoadMoreChapters);
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

      // fetch first batch of chapters
      final chapters = await _listChapters(
        mangaId: MangaId(event.mangaId),
        ascending: state.ascending,
        languageFilter: const LanguageCode('en'),
        offset: 0,
        limit: pageSize,
      );

      emit(state.copyWith(
        status: MangaDetailStatus.success,
        manga: manga,
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
    // Khi đổi sort asc/desc, reload danh sách chapter từ đầu
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

    emit(state.copyWith(
      status: MangaDetailStatus.loadingMoreChapters,
    ));

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
}
