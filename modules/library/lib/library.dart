// modules/library/lib/library.dart

// Presentation
export 'presentation/bloc/favorites_bloc.dart';
export 'presentation/bloc/history_bloc.dart';
export 'presentation/widgets/favorite_grid.dart';
export 'presentation/widgets/history_list.dart';
export 'presentation/pages/library_shell_page.dart';

// Domain
export 'domain/entities/favorite_item.dart';
export 'domain/entities/reading_progress.dart';
export 'domain/repositories/library_repository.dart'; // Abstract

// Application
export 'application/usecases/toggle_favorite.dart';
export 'application/usecases/get_favorites.dart';
export 'application/usecases/save_read_progress.dart';
export 'application/usecases/get_continue_reading.dart';

// Infrastructure (Thêm cái này)
export 'infrastructure/datasources/library_firestore_ds.dart';
export 'infrastructure/repositories/library_repository_impl.dart';
// export 'infrastructure/datasources/library_local_ds.dart'; // Đã xóa

// Manifest
export 'library_module.dart';