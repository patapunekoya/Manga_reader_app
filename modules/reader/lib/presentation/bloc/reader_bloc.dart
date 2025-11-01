// lib/presentation/bloc/reader_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/page_image.dart';
import '../../domain/value_objects/page_index.dart';
import '../../application/usecases/get_chapter_pages.dart';
import '../../application/usecases/prefetch_pages.dart';
import '../../application/usecases/report_image_error.dart';

part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetChapterPages _getChapterPages;
  final PrefetchPages _prefetchPages;
  final ReportImageError _reportImageError;

  ReaderBloc({
    required GetChapterPages getChapterPages,
    required PrefetchPages prefetchPages,
    required ReportImageError reportImageError,
  })  : _getChapterPages = getChapterPages,
        _prefetchPages = prefetchPages,
        _reportImageError = reportImageError,
        super(const ReaderState.initial()) {
    on<ReaderLoadChapter>(_onLoadChapter);
    on<ReaderSetCurrentPage>(_onSetCurrentPage);
    on<ReaderReportImageFailed>(_onReportImageFailed);
  }

  Future<void> _onLoadChapter(
    ReaderLoadChapter event,
    Emitter<ReaderState> emit,
  ) async {
    emit(state.copyWith(
      status: ReaderStatus.loading,
      chapterId: event.chapterId,
    ));

    try {
      final pages = await _getChapterPages(
        chapterId: event.chapterId,
      );

      emit(state.copyWith(
        status: ReaderStatus.success,
        pages: pages,
        currentPage: const PageIndex(0),
        errorMessage: null,
      ));

      // Prefetch mấy trang đầu kế tiếp
      await _prefetchPages(
        pages: pages.take(3).toList(),
      );

      // TODO: load last progress từ library (để nhảy tới page đã đọc)
      // emit(state.copyWith(currentPage: PageIndex(savedPage)));
    } catch (e) {
      emit(state.copyWith(
        status: ReaderStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetCurrentPage(
    ReaderSetCurrentPage event,
    Emitter<ReaderState> emit,
  ) async {
    // update current page user đang xem
    emit(state.copyWith(currentPage: event.pageIndex));

    // Prefetch sớm khi sắp tới cuối
    final total = state.pages.length;
    final cur = event.pageIndex.value;
    if (total - cur < 4 && total > 0) {
      final tail = state.pages.skip(cur).take(5).toList();
      await _prefetchPages(pages: tail);
    }

    // TODO: gọi save progress sang module library,
    // ví dụ saveReadProgress(mangaId, chapterId, curPage)
  }

  Future<void> _onReportImageFailed(
    ReaderReportImageFailed event,
    Emitter<ReaderState> emit,
  ) async {
    // just forward, don't touch UI state
    await _reportImageError(
      chapterId: state.chapterId,
      pageIndex: event.pageIndex,
      imageUrl: event.imageUrl,
    );
  }
}
