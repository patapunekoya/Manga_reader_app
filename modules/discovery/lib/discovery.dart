// modules/discovery/lib/discovery.dart

// Presentation
export 'presentation/widgets/feed_carousel.dart';
export 'presentation/bloc/discovery_bloc.dart';

// Domain
export 'domain/entities/feed_item.dart';
export 'domain/value_objects/feed_cursor.dart';
export 'domain/repositories/discovery_repository.dart'; // Abstract Repo

// Application
export 'application/usecases/get_trending.dart';
export 'application/usecases/get_latest_updates.dart';

// Infrastructure (Thêm cái này để Injection nhìn thấy)
export 'infrastructure/datasources/discovery_remote_ds.dart';
export 'infrastructure/repositories/discovery_repository_impl.dart';

// Module Manifest (Để App gọi)
export 'discovery_module.dart';