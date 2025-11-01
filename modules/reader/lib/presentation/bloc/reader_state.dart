// lib/presentation/bloc/reader_state.dart
part of 'reader_bloc.dart';

enum ReaderStatus {
  initial,
  loading,
  success,
  failure,
}

class ReaderState extends Equatable {
  final ReaderStatus status;
  final String chapterId;
  final List<PageImage> pages;
  final PageIndex currentPage;
  final String? errorMessage;

  const ReaderState({
    required this.status,
    required this.chapterId,
    required this.pages,
    required this.currentPage,
    required this.errorMessage,
  });

  const ReaderState.initial()
      : status = ReaderStatus.initial,
        chapterId = '',
        pages = const [],
        currentPage = const PageIndex(0),
        errorMessage = null;

  ReaderState copyWith({
    ReaderStatus? status,
    String? chapterId,
    List<PageImage>? pages,
    PageIndex? currentPage,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      chapterId: chapterId ?? this.chapterId,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chapterId,
        pages,
        currentPage,
        errorMessage,
      ];
}
