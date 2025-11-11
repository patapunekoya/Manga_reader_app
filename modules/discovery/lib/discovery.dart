/// discovery.dart
///
/// -----------------------------------------------------------------------------
/// Barrel Export cho module `discovery`
/// -----------------------------------------------------------------------------
/// Mục đích file:
/// - Gom toàn bộ **public API** của module discovery vào một điểm duy nhất.
/// - App chính hoặc các module khác chỉ cần:
///
///       import 'package:discovery/discovery.dart';
///
///   thay vì phải import lẻ tẻ từng file.
///
/// Vai trò trong kiến trúc dự án:
/// - Đây là "cổng giao tiếp" (public surface) của module.
/// - Các file bên trong module có thể thay đổi cấu trúc thư mục tùy ý,
///   nhưng miễn là barrel này export đúng, phần còn lại của app sẽ không bị ảnh hưởng.
/// - Giúp giữ module `discovery` **độc lập**, **gọn**, và **dễ bảo trì**.
///
/// Những thứ được export:
/// -----------------------------------------------------------------------------
/// 1) Widgets UI:
///    - `FeedCarousel`: widget hiển thị list manga theo dạng băng chuyền ngang.
///
/// 2) Bloc:
///    - `DiscoveryBloc`: quản lý trạng thái trending & latest updates.
///      Home Screen chỉ cần bloc này để load dữ liệu.
///
/// 3) Domain Entities & Value Objects:
///    - `FeedItem`: item manga rút gọn để show ở Home.
///    - `FeedCursor`: VO làm tham số phân trang cho usecase.
///
/// 4) Application Usecases:
///    - `GetTrending`
///    - `GetLatestUpdates`
///   -> Cho phép module ngoài có thể gọi trực tiếp logic nghiệp vụ discovery nếu cần.
///
/// Lưu ý:
/// - Tuyệt đối không export các file infrastructure (datasource, repository_impl).
///   Vì đó là phần nội bộ module, không phải public API.
/// -----------------------------------------------------------------------------

export 'presentation/widgets/feed_carousel.dart';
export 'presentation/bloc/discovery_bloc.dart';

export 'domain/entities/feed_item.dart';
export 'domain/value_objects/feed_cursor.dart';

export 'application/usecases/get_trending.dart';
export 'application/usecases/get_latest_updates.dart';
