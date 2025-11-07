// modules/reader/lib/presentation/bloc/reader_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/page_image.dart';
import '../../domain/value_objects/page_index.dart';

// Usecases
import '../../application/usecases/get_chapter_pages.dart';
import '../../application/usecases/prefetch_pages.dart';
import '../../application/usecases/report_image_error.dart';
import '../../application/usecases/save_read_progress.dart';

part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetChapterPages _getChapterPages;
  final PrefetchPages _prefetchPages;
  final ReportImageError _reportImageError;
  final SaveReadProgress _saveReadProgress;

  ReaderBloc({
    required GetChapterPages getChapterPages,
    required PrefetchPages prefetchPages,
    required ReportImageError reportImageError,
    required SaveReadProgress saveReadProgress,
  })  : _getChapterPages = getChapterPages,
        _prefetchPages = prefetchPages,
        _reportImageError = reportImageError,
        _saveReadProgress = saveReadProgress,
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
      // set metadata để có đủ dữ liệu lưu progress (CHAPTER-ONLY)
      mangaId: event.mangaId ?? state.mangaId,
      mangaTitle: event.mangaTitle ?? state.mangaTitle,
      coverImageUrl: event.coverImageUrl ?? state.coverImageUrl,
      chapterNumber: event.chapterNumber ?? state.chapterNumber,
    ));

    try {
      final pages = await _getChapterPages(
        chapterId: event.chapterId,
      );

      // resume page nếu cần (vẫn để 0 vì CHAPTER-ONLY)
      final startIndex = 0;

      emit(state.copyWith(
        status: ReaderStatus.success,
        pages: pages,
        currentPage: PageIndex(startIndex),
        errorMessage: null,
      ));

      // Prefetch mấy trang đầu kế tiếp
      await _prefetchPages(
        pages: pages.take(3).toList(),
      );

      // LƯU TIẾN TRÌNH THEO CHAPTER (ngay khi mở chapter)
      if (state.mangaId.isNotEmpty && state.chapterId.isNotEmpty) {
        await _saveReadProgress(
          mangaId: state.mangaId,
          mangaTitle: state.mangaTitle,
          coverImageUrl:
              state.coverImageUrl.isEmpty ? null : state.coverImageUrl,
          chapterId: state.chapterId,
          chapterNumber: state.chapterNumber,

        );
      }
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
    // vẫn cập nhật current page để UI hiển thị 1/ N
    emit(state.copyWith(currentPage: event.pageIndex));

    // Prefetch sớm khi sắp tới cuối
    final total = state.pages.length;
    final cur = event.pageIndex.value;
    if (total - cur < 4 && total > 0) {
      final tail = state.pages.skip(cur).take(5).toList();
      await _prefetchPages(pages: tail);
    }

    // CHAPTER-ONLY: Không lưu page nữa.
    // Nếu anh muốn lưu thời điểm “đang đọc” cũng được, nhưng vẫn đánh dấu theo chapter.
    // => bỏ _saveReadProgress ở đây.
  }

  Future<void> _onReportImageFailed(
    ReaderReportImageFailed event,
    Emitter<ReaderState> emit,
  ) async {
    await _reportImageError(
      chapterId: state.chapterId,
      pageIndex: event.pageIndex,
      imageUrl: event.imageUrl,
    );
  }
}
