/// discovery.dart
///
/// Barrel export cho module `discovery`.
/// App chính chỉ cần import 1 file này thay vì import từng thứ lẻ.
/// Ví dụ ở Home module hay app shell có thể:
///   import 'package:discovery/discovery.dart';
///
/// Chúng ta export:
/// - Widgets dùng để hiển thị feed trên Home (feed_carousel)
/// - Bloc để Home có thể điều khiển/đọc state nếu muốn
/// - Usecases nếu module ngoài cần xài trực tiếp (ít thôi)
/// - Entity cần show ra UI (FeedItem)

export 'presentation/widgets/feed_carousel.dart';
export 'presentation/bloc/discovery_bloc.dart';

export 'domain/entities/feed_item.dart';
export 'domain/value_objects/feed_cursor.dart';

export 'application/usecases/get_trending.dart';
export 'application/usecases/get_latest_updates.dart';
