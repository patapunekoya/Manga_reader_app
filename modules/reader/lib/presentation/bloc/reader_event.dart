// lib/presentation/bloc/reader_event.dart
part of 'reader_bloc.dart';

@immutable
abstract class ReaderEvent extends Equatable {
  const ReaderEvent();
  @override
  List<Object?> get props => [];
}

class ReaderLoadChapter extends ReaderEvent {
  final String chapterId;
  const ReaderLoadChapter(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
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
