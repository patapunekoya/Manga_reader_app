// lib/infrastructure/datasources/reader_remote_ds.dart
import 'package:dio/dio.dart';

/// ReaderRemoteDataSource:
/// Nói chuyện trực tiếp với MangaDex at-home server.
/// Trả về raw data:
/// {
///   "baseUrl": "...",
///   "chapter": {
///     "hash": "...",
///     "data": ["p1.jpg","p2.jpg",...],
///     "dataSaver": ["p1-saver.jpg",...]
///   }
/// }
///
/// Ta để RepositoryImpl xử lý map -> PageImage.

class ReaderRemoteDataSource {
  final Dio _dio;
  ReaderRemoteDataSource(this._dio);

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
