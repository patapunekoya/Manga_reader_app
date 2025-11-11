// lib/infrastructure/datasources/catalog_local_ds.dart

/// ======================================================================
/// DataSource: CatalogLocalDataSource
///
/// Vai trò (tầng Infrastructure):
///   - Đây là local datasource dành riêng cho Catalog module.
///   - Mục đích là lưu trữ cache nhẹ: tên truyện, mô tả ngắn, coverImageUrl,
///     availableLanguages, hoặc thậm chí danh sách chapter rút gọn.
///   - Giúp app phản hồi nhanh hơn khi offline hoặc khi user mở lại trang.
///   - Tách local storage khỏi Repository để đảm bảo Single Responsibility.
///
/// Trạng thái hiện tại:
///   - Đây chỉ là “stub” (khung) để đúng kiến trúc Clean/DDD.
///   - Chưa implement gì bên trong.
///   - Sau này có thể dùng Hive, SharedPreferences hoặc LocalStorage.
///
/// Tải trọng tương lai có thể thêm:
///   - saveMangaPreview(MangaPreview preview)
///   - getMangaPreview(MangaId id)
///   - cacheChapterList(id, chapters, expiresAt)
///   - clearExpirations()
///
/// Lưu ý kiến trúc:
///   - Datasource chỉ đọc/ghi dữ liệu local.
///   - Không mapping JSON hay gọi API.
///   - RepositoryImpl sẽ gọi local → remote → merge và trả Entity.
/// ======================================================================

class CatalogLocalDataSource {
  const CatalogLocalDataSource();

  // TODO: implement Hive cache nếu muốn cho phiên bản tiếp theo.
}
