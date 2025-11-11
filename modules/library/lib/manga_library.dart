// lib/library.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là **Barrel File** cho module `library_manga` (hoặc `library` tùy dự án đặt tên).
// Barrel export giúp module bên ngoài chỉ cần import duy nhất:
//
//    import 'package:library/library.dart';
//
// thay vì phải import từng file nhỏ lẻ như bloc, widgets, usecases, entities.
//
// Ý NGHĨA / LỢI ÍCH
// ----------------
// - Gom toàn bộ API public của module vào một chỗ.
// - Che giấu cấu trúc thư mục nội bộ, chỉ expose những thứ cần thiết.
// - Giảm số lượng import lộn xộn ở App Shell.
// - Dễ scale dự án khi có nhiều module con.
//
// QUẢN LÝ GIỚI HẠN MODULE
// ------------------------
// Chỉ export:
// - Bloc: FavoritesBloc, HistoryBloc
// - Widgets: FavoriteGrid, HistoryList
// - Usecases liên quan library
// - Entities: FavoriteItem, ReadingProgress
//
// Không export datasources hoặc repository impl vì đó là chi tiết nội bộ.
// App chỉ dùng qua usecases/bloc.
//
// LƯU Ý KHI MỞ RỘNG
// -----------------
// - Nếu module library có thêm các feature mới (Search in Favorites, Sort,...),
//   chỉ export public API (widgets/usecases) thật sự cần share ra ngoài.
// - Đảm bảo App Shell chỉ biết đến abstract layer, không phụ thuộc code internal.
//

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
