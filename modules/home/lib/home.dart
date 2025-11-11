// lib/home.dart
//
// ---------------------------------------------------------------------------
// Barrel export cho module HOME
// ---------------------------------------------------------------------------
// File này gom tất cả những thứ Home module muốn public ra ngoài,
// để App Shell hoặc module khác chỉ cần import duy nhất:
//
//    import 'package:home/home.dart';
//
// => Không phải import từng file lẻ tẻ từ nhiều thư mục.
//
// Đây là chuẩn kiến trúc Modularization / DDD: mỗi module có 1 "cổng"
// duy nhất để expose API công khai của module.
//
// Những thứ được export:
// - Bloc (điều khiển màn Home)
// - Widgets UI (Continue reading strip, Quick filters)
// - Usecase build_home_vm (gom dữ liệu: history + trending + latest)
// - Các entity/model VM cần thiết cho module ngoài.
//
// KHÔNG export các file nội bộ không cần thiết để tránh lộ chi tiết
// implementation (encapsulation).
// ---------------------------------------------------------------------------

export 'presentation/bloc/home_bloc.dart';                // Bloc quản lý state trang Home
export 'presentation/widgets/continue_reading_strip.dart'; // Widget hiển thị danh sách truyện đang đọc dở
export 'presentation/widgets/quick_filters.dart';          // Widget filter tag nhanh
export 'application/usecases/build_home_vm.dart';          // Usecase build ViewModel Home
export 'domain/entities/home_section.dart';                // Entity/VM home section
