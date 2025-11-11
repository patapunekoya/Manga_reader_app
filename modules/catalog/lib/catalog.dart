// lib/catalog.dart
//
// PURPOSE
// - "Barrel export" tập trung: một điểm import duy nhất cho module `catalog`.
// - App shell (SearchShellPage, MangaDetailShellPage, …) chỉ cần
//   `import 'package:catalog/catalog.dart';` là dùng được tất cả public API.
// - Giúp:
//   • Giấu cấu trúc thư mục nội bộ của module.
//   • Giảm số lượng import rời rạc ở phía App.
//   • Dễ refactor: đổi đường dẫn nội bộ mà không ảnh hưởng caller.
//
// PHẠM VI EXPORT (PUBLIC SURFACE)
// - Widgets UI (SearchView, MangaDetailView, MangaCard, ChapterTile)
// - BLoC (SearchBloc, MangaDetailBloc) để shell có thể cung cấp/quan sát state
// - Entities + ValueObjects dùng ở UI và BLoC
// - UseCases cho layer trình bày gọi vào domain thông qua repository
//
// LƯU Ý SỬ DỤNG
// - Đây là public API của module. Các file nội bộ (DTO, data source, repository impl)
//   KHÔNG export ra đây để tránh phụ thuộc rò rỉ.
// - Khi thêm/bớt tính năng, chỉ export những thành phần cần public.
// - Nếu tách nhỏ module (ví dụ: tách reader, library…), tạo barrel riêng cho từng module.

export 'presentation/widgets/search_view.dart';      // UI trang tìm kiếm: nhập query/genre, grid kết quả, infinite scroll
export 'presentation/widgets/manga_detail_view.dart';// UI trang chi tiết: header (cover, meta, action), danh sách chapter + lọc ngôn ngữ
export 'presentation/widgets/manga_card.dart';       // Thẻ hiển thị manga trong grid/list: cover, title, status, subtext
export 'presentation/widgets/chapter_tile.dart';     // Dòng chapter: tiêu đề/Ch.N, icon “đã đọc”, mã ngôn ngữ

export 'presentation/bloc/search_bloc.dart';         // BLoC tìm kiếm: trạng thái query/genre, phân trang, lỗi, loadingMore
export 'presentation/bloc/manga_detail_bloc.dart';   // BLoC chi tiết: detail, chapters, sort asc/desc, filter ngôn ngữ, favorite

export 'domain/entities/manga.dart';                 // Entity Manga: dữ liệu sạch cho UI (title, tags, status, cover, languages, …)
export 'domain/entities/chapter.dart';               // Entity Chapter: id, mangaId, chapterNumber, title, language, updatedAt
export 'domain/value_objects/manga_id.dart';         // VO MangaId: tránh nhầm lẫn String tự do với id hợp lệ
export 'domain/value_objects/chapter_id.dart';       // VO ChapterId: tương tự cho id chapter

export 'application/usecases/search_manga.dart';     // UC search: query + tùy chọn genre, offset/limit
export 'application/usecases/get_manga_detail.dart'; // UC detail: lấy thông tin manga + relationships
export 'application/usecases/list_chapters.dart';    // UC liệt kê chapter: sort, filter theo LanguageCode? + phân trang
