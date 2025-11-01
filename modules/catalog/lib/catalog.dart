// lib/catalog.dart
//
// Barrel export cho module `catalog`.
// App shell (SearchShellPage, MangaDetailShellPage) chỉ cần import 'package:catalog/catalog.dart';

export 'presentation/widgets/search_view.dart';
export 'presentation/widgets/manga_detail_view.dart';
export 'presentation/widgets/manga_card.dart';
export 'presentation/widgets/chapter_tile.dart';

export 'presentation/bloc/search_bloc.dart';
export 'presentation/bloc/manga_detail_bloc.dart';

export 'domain/entities/manga.dart';
export 'domain/entities/chapter.dart';
export 'domain/value_objects/manga_id.dart';
export 'domain/value_objects/chapter_id.dart';

export 'application/usecases/search_manga.dart';
export 'application/usecases/get_manga_detail.dart';
export 'application/usecases/list_chapters.dart';
