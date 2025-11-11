import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/manga_detail_bloc.dart';

/// ======================================================================
/// SCREEN: MangaDetailScreen
///
/// Mục đích:
///   - Là entry screen đơn giản để dựng BLoC và render UI chi tiết manga.
///   - ĐÂY LÀ VỎ BỌC (shell) — phần UI chi tiết thực sự nên tách ra widget riêng
///     (ví dụ: MangaDetailView) để dễ test và tái sử dụng.
///
/// Cách dùng (DI với GetIt):
///   - Thay `throw UnimplementedError()` bằng resolve từ GetIt
///     và dispatch event load dữ liệu ngay khi tạo BLoC.
///     Ví dụ:
///       return BlocProvider(
///         create: (_) => GetIt.I<MangaDetailBloc>()
///           ..add(MangaDetailLoadRequested(mangaId)),
///         child: BlocBuilder<...>(
///           ...
///         ),
///       );
///
/// Vòng đời & Render:
///   - `BlocBuilder` sẽ lắng nghe `MangaDetailState`.
///   - Dựa vào `state.status` để hiển thị:
///       • loading: spinner
///       • failure: thông báo lỗi (state.errorMessage)
///       • success: body chi tiết (title/cover/desc/chapters...)
///   - Hiện tại phần UI chi tiết đang để TODO, bạn map sang view thật của bạn.
///
/// Lưu ý:
///   - Không khởi tạo BLoC trong build theo kiểu tạo mới nhiều lần.
///     Sử dụng `BlocProvider` cung cấp 1 instance cho subtree.
///   - Nếu tách phần UI ra `MangaDetailView`, screen này chỉ còn nhiệm vụ DI.
/// ======================================================================
class MangaDetailScreen extends StatelessWidget {
  final String mangaId;
  const MangaDetailScreen({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // NOTE: Thay thế bằng GetIt để cấp BLoC thực:
      // create: (_) => GetIt.I<MangaDetailBloc>()..add(MangaDetailLoadRequested(mangaId)),
      create: (_) =>
          // Placeholder: giữ nguyên theo yêu cầu, KHÔNG đổi logic.
          // Khi triển khai thực tế, hãy xóa dòng dưới và dùng GetIt như comment ở trên.
          throw UnimplementedError(), // bạn sẽ nối GetIt vào đây

      child: BlocBuilder<MangaDetailBloc, MangaDetailState>(
        builder: (context, state) {
          // Gợi ý khung xử lý theo status:
          // if (state.status == MangaDetailStatus.loading || state.status == MangaDetailStatus.initial) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          // if (state.status == MangaDetailStatus.failure) {
          //   return Center(child: Text(state.errorMessage ?? 'Đã xảy ra lỗi'));
          // }
          // if (state.status == MangaDetailStatus.success && state.manga != null) {
          //   return _DetailBody(
          //     title: state.manga!.title,
          //     coverUrl: state.manga!.coverImageUrl,
          //     authors: state.manga!.authorName,
          //     year: state.manga!.year,
          //     tags: state.manga!.tags,
          //     description: state.manga!.description,
          //     chapters: state.chapters,
          //   );
          // }

          // ví dụ layout mong muốn khi success:
          // return _DetailBody(
          //   title: state.manga.title,
          //   coverUrl: state.manga.coverUrl,
          //   authors: state.manga.authors,
          //   year: state.manga.year,
          //   tags: state.manga.tags,
          //   description: state.manga.description,
          //   chapters: state.chapters,
          // );

          // TODO: thay thế bằng UI thực tế (MangaDetailView) sau khi wire xong DI + event.
          return const Center(child: Text('TODO detail UI'));
        },
      ),
    );
  }
}
