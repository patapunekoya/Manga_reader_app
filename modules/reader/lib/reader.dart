// lib/reader.dart
//
// Barrel export cho module 'reader'.
//
// Đây là "cổng xuất chính" cho toàn bộ module Reader.
// App shell (ví dụ ReaderShellPage hoặc toàn app) KHÔNG cần import từng file lẻ
// như: reader_bloc.dart, reader_view.dart, get_chapter_pages.dart,...
// mà chỉ cần:
//      import 'package:reader/reader.dart';
//
// Điều này giúp module hóa đúng chuẩn: 
// - Giấu cấu trúc thư mục bên trong.
// - Tối ưu import gọn gàng.
// - Tăng tính độc lập giữa các module (clean, DDD-friendly).
//
// Quy tắc barrel export: 
// - Chỉ export những thứ PUBLIC mà module ngoài cần dùng.
// - Không export nội bộ infra/datasource.
// - Bloc + Widget + Usecase + ValueObject + Entities => xuất ra để UI shell và module khác dùng.
//
// Các phần bên dưới là những phần module reader expose ra ngoài:

export 'presentation/widgets/reader_view.dart';      // Widget chính để hiển thị danh sách trang manga + scroll
export 'presentation/widgets/reader_toolbar.dart';   // Thanh toolbar đáy: Back / Prev Chap / Next Chap
export 'presentation/bloc/reader_bloc.dart';         // Bloc quản lý trạng thái đọc, current page, load chapter

export 'application/usecases/get_chapter_pages.dart';   // Usecase lấy danh sách trang từ repository
export 'application/usecases/prefetch_pages.dart';      // Usecase prefetch trang sắp tới
export 'application/usecases/report_image_error.dart';  // Usecase báo lỗi ảnh cho repo

export 'domain/entities/page_image.dart';           // Entity đại diện cho 1 trang
export 'domain/value_objects/page_index.dart';      // Value object cho index trang
export 'domain/value_objects/at_home_url.dart';     // Value object build URL ảnh từ MangaDex at-home
