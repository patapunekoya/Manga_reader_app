// lib/library.dart
//
// Barrel export cho module library
// App shell chỉ cần import 'package:library/library.dart';

export 'presentation/bloc/favorites_bloc.dart';
export 'presentation/bloc/history_bloc.dart';

export 'presentation/widgets/favorite_grid.dart';
export 'presentation/widgets/history_list.dart';

export 'application/usecases/toggle_favorite.dart';
export 'application/usecases/get_favorites.dart';
export 'application/usecases/save_read_progress.dart';
export 'application/usecases/get_continue_reading.dart';

export 'domain/entities/favorite_item.dart';
export 'domain/entities/reading_progress.dart';
