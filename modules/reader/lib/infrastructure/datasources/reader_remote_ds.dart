// lib/infrastructure/datasources/reader_remote_ds.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là DataSource tầng **infrastructure**, chịu trách nhiệm gọi trực tiếp
// MangaDex API /at-home/server/{chapterId} để lấy:
//   - baseUrl  (server host để load ảnh)
//   - hash     (mã hash dùng để build URL ảnh)
//   - danh sách file ảnh: data[] và dataSaver[]
//
// DataSource *không parse* sang PageImage. Nó chỉ trả raw JSON.
// Tầng RepositoryImpl sẽ map raw JSON -> entity PageImage.
//
// Lưu ý:
//   ✅ Dio phải được register trong GetIt với baseUrl: https://api.mangadex.org
//   ✅ Đây là endpoint đặc biệt của MangaDex dành cho chapter images (At-Home API).
//   ✅ Nếu MangaDex trả dạng sai hoặc lỗi, ta throw Exception để Bloc bắt.
//
// Ví dụ response:
// {
//   "baseUrl": "https://uploads-mangadex.org",
//   "chapter": {
//     "hash": "824d0f...",
//     "data": ["001.webp","002.webp", ...],
//     "dataSaver": ["001.jpg", ...]
//   }
// }

import 'package:dio/dio.dart';

/// ReaderRemoteDataSource:
/// ------------------------
/// Nhiệm vụ:
///   - Gọi endpoint /at-home/server/{chapterId}
///   - Validate kiểu dữ liệu
///   - Trả raw Map<String, dynamic> để repo xử lý tiếp
class ReaderRemoteDataSource {
  final Dio _dio;
  ReaderRemoteDataSource(this._dio);

  /// fetchChapterPagesRaw():
  /// -----------------------
  /// Trả về raw JSON dùng để map thành AtHomeUrl + danh sách file ảnh.
  ///
  /// Nếu JSON không hợp lệ, ném Exception để tầng trên biết error.
  Future<Map<String, dynamic>> fetchChapterPagesRaw({
    required String chapterId,
  }) async {
    final resp = await _dio.get('/at-home/server/$chapterId');

    final data = resp.data;
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception("Invalid at-home response for $chapterId");
  }
}
