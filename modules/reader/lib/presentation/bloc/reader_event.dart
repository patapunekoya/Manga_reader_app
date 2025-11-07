// modules/reader/lib/presentation/bloc/reader_event.dart
part of 'reader_bloc.dart';

@immutable
abstract class ReaderEvent extends Equatable {
  const ReaderEvent();
  @override
  List<Object?> get props => [];
}

/// Load một chapter kèm metadata để có thể lưu/khôi phục progress.
/// [initialPageIndex] cho phép nhảy thẳng tới trang đã lưu (mặc định 0).
class ReaderLoadChapter extends ReaderEvent {
  final String chapterId;

  final String? mangaId;
  final String? mangaTitle;
  final String? coverImageUrl;
  final String? chapterNumber;

  final int initialPageIndex;

  const ReaderLoadChapter(
    this.chapterId, {
    this.mangaId,
    this.mangaTitle,
    this.coverImageUrl,
    this.chapterNumber,
    this.initialPageIndex = 0,
  });

  @override
  List<Object?> get props => [
        chapterId,
        mangaId,
        mangaTitle,
        coverImageUrl,
        chapterNumber,
        initialPageIndex,
      ];
}

class ReaderSetCurrentPage extends ReaderEvent {
  final PageIndex pageIndex;
  const ReaderSetCurrentPage(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class ReaderReportImageFailed extends ReaderEvent {
  final int pageIndex;
  final String imageUrl;
  const ReaderReportImageFailed({
    required this.pageIndex,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [pageIndex, imageUrl];
}
