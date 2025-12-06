// modules/reader/lib/reader.dart

// Presentation
export 'presentation/widgets/reader_view.dart';
export 'presentation/widgets/reader_toolbar.dart';
export 'presentation/bloc/reader_bloc.dart';
export 'presentation/page/reader_shell_page.dart';

// Domain
export 'domain/entities/page_image.dart';
export 'domain/value_objects/page_index.dart';
export 'domain/value_objects/at_home_url.dart';
export 'domain/repositories/reader_repository.dart'; // Abstract

// Application
export 'application/usecases/get_chapter_pages.dart';
export 'application/usecases/prefetch_pages.dart';
export 'application/usecases/report_image_error.dart';
export 'application/usecases/save_read_progress.dart'; // Facade

// Infrastructure (Thêm cái này)
export 'infrastructure/datasources/reader_remote_ds.dart';
export 'infrastructure/repositories/reader_repository_impl.dart';

// Manifest
export 'reader_module.dart';