// modules/reader/lib/presentation/bloc/reader_event.dart
//
// Đây là toàn bộ các EVENT mà ReaderBloc có thể nhận.
//
// Event = tín hiệu từ UI -> Bloc xử lý.
//
// 1) ReaderLoadChapter: Khi user mở 1 chapter mới.
//    - Gửi kèm metadata để Bloc có đủ info lưu progress:
//        mangaId, mangaTitle, coverImageUrl, chapterNumber
//    - initialPageIndex: trang bắt đầu (thường = 0 vì CHAPTER-ONLY)
//
// 2) ReaderSetCurrentPage: Khi user lướt tới trang mới.
//    - PageIndex là ValueObject -> tránh lẫn int.
//
// 3) ReaderReportImageFailed: Khi 1 ảnh load bị lỗi.
//    - Bloc sẽ gọi usecase ReportImageError (mặc định chỉ log).
//
// Tất cả event extends Equatable để BLoC so sánh state/event tối ưu.
//

part of 'reader_bloc.dart';

@immutable
abstract class ReaderEvent extends Equatable {
  const ReaderEvent();
  @override
  List<Object?> get props => [];
}

// ===========================================================================
// EVENT 1: LOAD CHAPTER
// ===========================================================================
// Khi UI chuyển vào màn Reader và muốn mở 1 chapter,
// nó sẽ gửi event này.
//
// Các tham số:
//
// chapterId        = ID của chapter cần load ảnh
// mangaId          = ID manga, dùng để lưu ReadingProgress
// mangaTitle       = tiêu đề truyện, cũng để lưu progress
// coverImageUrl    = ảnh bìa hiển thị ở History
// chapterNumber    = số chapter hiển thị cho user
// initialPageIndex = trang bắt đầu (CHAPTER-ONLY thì luôn 0)
//
// ReaderBloc sẽ:
// - emit loading
// - gọi GetChapterPages
// - emit success + danh sách PageImage
// - prefetch vài trang sắp tới
// - saveReadProgress (theo CHAPTER)
// ===========================================================================
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

// ===========================================================================
// EVENT 2: SET CURRENT PAGE
// ===========================================================================
// Khi user scroll / swipe sang 1 trang khác,
// UI sẽ gửi event này.
//
// Bloc sẽ:
// - update currentPage
// - prefetch vài trang tiếp theo nếu gần cuối
//
// PageIndex là ValueObject để tránh sai số và ép kiểu nhầm.
//
class ReaderSetCurrentPage extends ReaderEvent {
  final PageIndex pageIndex;
  const ReaderSetCurrentPage(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

// ===========================================================================
// EVENT 3: REPORT IMAGE FAILED
// ===========================================================================
// Khi Image.network load lỗi (invalid URL / 404 / timeout),
// UI sẽ fire event này.
//
// Bloc -> gọi ReportImageError để log lỗi.
// MVP: chỉ print, không crash, không retry.
//
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
