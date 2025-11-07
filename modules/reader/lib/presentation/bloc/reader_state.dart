// modules/reader/lib/presentation/bloc/reader_state.dart
part of 'reader_bloc.dart';

enum ReaderStatus {
  initial,
  loading,
  success,
  failure,
}

class ReaderState extends Equatable {
  final ReaderStatus status;

  // chapter đang đọc
  final String chapterId;
  final List<PageImage> pages;
  final PageIndex currentPage;

  // metadata để lưu/khôi phục progress
  final String mangaId;
  final String mangaTitle;
  final String coverImageUrl;
  final String chapterNumber;

  final String? errorMessage;

  const ReaderState({
    required this.status,
    required this.chapterId,
    required this.pages,
    required this.currentPage,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverImageUrl,
    required this.chapterNumber,
    required this.errorMessage,
  });

  const ReaderState.initial()
      : status = ReaderStatus.initial,
        chapterId = '',
        pages = const [],
        currentPage = const PageIndex(0),
        mangaId = '',
        mangaTitle = '',
        coverImageUrl = '',
        chapterNumber = '',
        errorMessage = null;

  ReaderState copyWith({
    ReaderStatus? status,
    String? chapterId,
    List<PageImage>? pages,
    PageIndex? currentPage,
    String? mangaId,
    String? mangaTitle,
    String? coverImageUrl,
    String? chapterNumber,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      chapterId: chapterId ?? this.chapterId,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chapterId,
        pages,
        currentPage,
        mangaId,
        mangaTitle,
        coverImageUrl,
        chapterNumber,
        errorMessage,
      ];
}
