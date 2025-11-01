// lib/reader.dart
//
// Barrel export cho module 'reader'.
// App shell (ReaderShellPage) chỉ cần import cái này.

export 'presentation/widgets/reader_view.dart';
export 'presentation/widgets/reader_toolbar.dart';
export 'presentation/bloc/reader_bloc.dart';

export 'application/usecases/get_chapter_pages.dart';
export 'application/usecases/prefetch_pages.dart';
export 'application/usecases/report_image_error.dart';

export 'domain/entities/page_image.dart';
export 'domain/value_objects/page_index.dart';
export 'domain/value_objects/at_home_url.dart';
