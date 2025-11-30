// modules/reader/lib/presentation/bloc/reader_bloc.dart
//
// Đây là BLoC điều khiển toàn bộ Reader Screen:
// - Load chapter
// - Trả về danh sách PageImage
// - Điều hướng page (PageIndex)
// - Prefetch trang sắp tới
// - Báo lỗi ảnh
// - Lưu tiến trình đọc (CHAPTER-ONLY)
//
// Luồng chuẩn khi user mở 1 chapter:
// UI -> ReaderLoadChapter(chapterId, mangaId, mangaTitle, cover, chapterNumber)
// Bloc -> gọi GetChapterPages -> emit success -> UI render pages
// Bloc -> lưu tiến trình ngay khi mở (saveReadProgress)
// Bloc -> prefetch vài trang đầu
//
// Khi user lướt page:
// UI -> ReaderSetCurrentPage(PageIndex)
// Bloc -> update currentPage
// Bloc -> prefetch trang sắp tới khi gần cuối
//
// Khi ảnh load lỗi:
// UI -> ReaderReportImageFailed
// Bloc -> reportImageError (log)
//
// ========================================================================

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
  // Các usecase bắt buộc phải inject vào
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
    // Khi user yêu cầu mở 1 chapter
    on<ReaderLoadChapter>(_onLoadChapter);

    // Khi user scroll sang 1 trang khác
    on<ReaderSetCurrentPage>(_onSetCurrentPage);

    // Khi 1 trang load ảnh bị lỗi
    on<ReaderReportImageFailed>(_onReportImageFailed);

    // THÊM HANDLER CHO SỰ KIỆN TẢI LẠI (RETRY)
    on<ReaderRetryLoad>(_onRetryLoad);
  }

  // ===========================================================================
  // 1) LOAD CHAPTER
  // ===========================================================================
  Future<void> _onLoadChapter(
    ReaderLoadChapter event,
    Emitter<ReaderState> emit,
  ) async {
    // Khi load, set trạng thái loading + set metadata để lưu progress
    emit(state.copyWith(
      status: ReaderStatus.loading,
      chapterId: event.chapterId,

      // Metadata cần để saveReadProgress
      mangaId: event.mangaId ?? state.mangaId,
      mangaTitle: event.mangaTitle ?? state.mangaTitle,
      coverImageUrl: event.coverImageUrl ?? state.coverImageUrl,
      chapterNumber: event.chapterNumber ?? state.chapterNumber,
    ));

    try {
      // Gọi API lấy toàn bộ danh sách PageImage của chapter
      final pages = await _getChapterPages(
        chapterId: event.chapterId,
      );

      // CHAPTER-ONLY: luôn bắt đầu ở trang 0
      final startIndex = 0;

      // Emit thành công -> UI dựng Reader
      emit(state.copyWith(
        status: ReaderStatus.success,
        pages: pages,
        currentPage: PageIndex(startIndex),
        errorMessage: null,
      ));

      // Prefetch vài trang tiếp theo (3 trang)
      await _prefetchPages(
        pages: pages.take(3).toList(),
      );

      // LƯU TIẾN TRÌNH THEO CHAPTER
      // Không lưu page nữa, chỉ lưu chapter + metadata
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

  // ===========================================================================
  // 2) SET CURRENT PAGE
  // ===========================================================================
  Future<void> _onSetCurrentPage(
    ReaderSetCurrentPage event,
    Emitter<ReaderState> emit,
  ) async {
    // Update current page để UI show 1/xx
    emit(state.copyWith(currentPage: event.pageIndex));

    // Prefetch khi gần tới cuối chapter
    final total = state.pages.length;
    final cur = event.pageIndex.value;

    if (total - cur < 4 && total > 0) {
      // Lấy thêm 5 trang sắp tới
      final tail = state.pages.skip(cur).take(5).toList();
      await _prefetchPages(pages: tail);
    }

    // Không lưu page-index, vì đang dùng CHAPTER-ONLY
  }

  // ===========================================================================
  // 3) REPORT IMAGE FAILED
  // ===========================================================================
  Future<void> _onReportImageFailed(
    ReaderReportImageFailed event,
    Emitter<ReaderState> emit,
  ) async {
    // Báo lỗi ảnh để analytics hoặc debug log
    await _reportImageError(
      chapterId: state.chapterId,
      pageIndex: event.pageIndex,
      imageUrl: event.imageUrl,
    );
  }
  
  // ===========================================================================
  // 4) RETRY LOAD CHAPTER (MỚI)
  // ===========================================================================
  /// Handler cho sự kiện Retry Load. 
  /// Dùng metadata đã lưu trong state để gọi lại _onLoadChapter.
  Future<void> _onRetryLoad(
    ReaderRetryLoad event,
    Emitter<ReaderState> emit,
  ) async {
    if (state.chapterId.isNotEmpty) {
      // Dùng lại logic _onLoadChapter, truyền lại metadata đã lưu trong state
      // (Giả sử logic load và metadata đã đủ để chạy lại)
      final retryEvent = ReaderLoadChapter(
        state.chapterId,
        mangaId: state.mangaId,
        mangaTitle: state.mangaTitle,
        coverImageUrl: state.coverImageUrl,
        chapterNumber: state.chapterNumber,
        initialPageIndex: state.currentPage.value, // Giữ nguyên trang hiện tại
      );
      await _onLoadChapter(retryEvent, emit);
    }
  }
}