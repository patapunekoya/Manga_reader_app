// modules/library/lib/presentation/widgets/favorite_grid.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Widget FavoriteGrid hiển thị lưới (GridView) các manga đã đánh dấu "Yêu thích"
// từ trạng thái của FavoritesBloc. Nó hỗ trợ:
//  - Trạng thái loading/initial: hiện CircularProgressIndicator
//  - Trạng thái failure: hiện thông báo lỗi
//  - Trạng thái success:
//      + Nếu danh sách rỗng: hiện text "Chưa có truyện yêu thích."
//      + Nếu có dữ liệu: render Grid 3 cột, mỗi item gồm ảnh bìa + tiêu đề
//  - Sự kiện tương tác:
//      + onTapManga: người dùng chạm vào item để đi tới màn chi tiết manga
//      + onLongPressManga: người dùng nhấn-giữ để xử lý gỡ khỏi yêu thích (confirm ở ngoài)
//
// PHỤ THUỘC/LIÊN QUAN
// --------------------
// - FavoritesBloc/FavoritesState: cung cấp danh sách FavoriteItem và trạng thái
// - FavoriteItem (domain): { id (mangaId), title, coverImageUrl, addedAt, updatedAt }
//
// GHI CHÚ THIẾT KẾ UI
// -------------------
// - Grid 3 cột, tỉ lệ (childAspectRatio) = 3/5 giúp bìa 3/4 + tiêu đề 2 dòng cân đối
// - Ảnh bìa ClipRRect bo góc 10. Nếu không có ảnh, show icon placeholder
// - Text tiêu đề: tối đa 2 dòng, ellipsis tránh tràn
//
// LƯU Ý TÍCH HỢP
// --------------
// - Bên ngoài phải cung cấp FavoritesBloc (BlocProvider) trước khi dùng FavoriteGrid
// - onLongPressManga chỉ phát ra callback; việc hiển thị dialog xác nhận và gọi
//   FavoritesToggleRequested hoặc removeFavorite là trách nhiệm của màn cha.
//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../../domain/entities/favorite_item.dart'; // <-- cần import để dùng FavoriteItem

class FavoriteGrid extends StatelessWidget {
  // Callback khi chạm vào một manga trong lưới -> điều hướng tới chi tiết
  final void Function(String mangaId)? onTapManga;

  /// NEW: nhấn-giữ để gỡ khỏi yêu thích (confirm ở ngoài)
  /// Gửi lên cả FavoriteItem để cha có đủ dữ liệu hiển thị dialog/undo...
  final void Function(FavoriteItem item)? onLongPressManga;

  const FavoriteGrid({
    super.key,
    this.onTapManga,
    this.onLongPressManga,
  });

  @override
  Widget build(BuildContext context) {
    // BlocBuilder lắng nghe FavoritesBloc để render theo trạng thái
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        // 1) Đang tải hoặc mới khởi tạo -> spinner
        if (state.status == FavoritesStatus.loading ||
            state.status == FavoritesStatus.initial) {
          return const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) Lỗi -> hiển thị thông báo lỗi
        if (state.status == FavoritesStatus.failure) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Lỗi tải danh sách yêu thích.\n${state.errorMessage ?? ''}",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          );
        }

        // 3) Thành công nhưng rỗng -> hint
        final items = state.items;
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Chưa có truyện yêu thích.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        // 4) Thành công có dữ liệu -> render Grid 3 cột
        return GridView.builder(
          shrinkWrap: true, // để nhúng trong SingleChildScrollView/ListView cha
          physics: const NeverScrollableScrollPhysics(), // cuộn theo cha
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,        // 3 cột
            mainAxisSpacing: 12,      // khoảng cách dọc giữa các ô
            crossAxisSpacing: 12,     // khoảng cách ngang giữa các ô
            childAspectRatio: 3 / 5,  // tỉ lệ ô: giúp cân bìa 3/4 + tiêu đề 2 dòng
          ),
          itemBuilder: (context, index) {
            final it = items[index];

            // GestureDetector để bắt tap & long-press
            return GestureDetector(
              onTap: () => onTapManga?.call(it.id.value),
              onLongPress: () => onLongPressManga?.call(it), // <-- thêm nè
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh bìa theo tỉ lệ 3/4, bo góc
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: it.coverImageUrl != null
                          ? Image.network(it.coverImageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF2A2A2D),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white38,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tiêu đề 2 dòng, đậm vừa, chống tràn
                  Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
