// modules/catalog/lib/catalog.dart

// Presentation
export 'presentation/widgets/search_view.dart';
export 'presentation/widgets/manga_detail_view.dart';
export 'presentation/widgets/manga_card.dart';
export 'presentation/widgets/chapter_tile.dart';
export 'presentation/bloc/search_bloc.dart';
export 'presentation/bloc/manga_detail_bloc.dart';
// Export Pages để MainShell import
export 'presentation/pages/search_shell_page.dart';
export 'presentation/pages/manga_detail_shell_page.dart';

// Domain
export 'domain/entities/manga.dart';
export 'domain/entities/chapter.dart';
export 'domain/value_objects/manga_id.dart';
export 'domain/value_objects/chapter_id.dart';
export 'domain/repositories/catalog_repository.dart'; // Abstract

// Application
export 'application/usecases/search_manga.dart';
export 'application/usecases/get_manga_detail.dart';
export 'application/usecases/list_chapters.dart';

// Infrastructure (Thêm cái này)
export 'infrastructure/datasources/catalog_remote_ds.dart';
export 'infrastructure/datasources/catalog_local_ds.dart';
export 'infrastructure/repositories/catalog_repository_impl.dart';

// Manifest
export 'catalog_module.dart';