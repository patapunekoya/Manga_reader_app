// lib/presentation/widgets/manga_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// BLoC + domain
import '../bloc/manga_detail_bloc.dart';
import '../../domain/entities/manga.dart';
import '../../domain/entities/chapter.dart';
import 'chapter_tile.dart';

// dùng để “Đọc tiếp”
import 'package:library_manga/application/usecases/get_continue_reading.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';


class MangaDetailView extends StatefulWidget {
  final String mangaId;
  final void Function(String chapterId)? onOpenChapter;
  final VoidCallback? onToggleFavorite;

  const MangaDetailView({
    super.key,
    required this.mangaId,
    this.onOpenChapter,
    this.onToggleFavorite,
  });

  @override
  State<MangaDetailView> createState() => _MangaDetailViewState();
}

class _MangaDetailViewState extends State<MangaDetailView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final bloc = context.read<MangaDetailBloc>();
    bloc.add(MangaDetailLoadRequested(widget.mangaId));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        bloc.add(const MangaDetailLoadMoreChapters());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ===== Helpers cho điều hướng =====

  void _openChapter(String chapterId, {int pageIndex = 0}) {
    if (widget.onOpenChapter != null) {
      widget.onOpenChapter!(chapterId);
    } else {
      // Không có callback thì thôi, nhưng từ bi nhắc nhẹ.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở chương (thiếu onOpenChapter).')),
      );
    }
  }

  // Lấy chương “đầu” theo sort hiện tại
  Chapter? _pickStartChapter(MangaDetailState st) {
    if (st.chapters.isEmpty) return null;
    // ascending == true => chương nhỏ nhất nằm ở đầu danh sách
    return st.ascending ? st.chapters.first : st.chapters.last;
  }

  // Lấy progress mới nhất theo mangaId
  Future<ReadingProgress?> _getLatestProgressForManga(String mangaId) async {
    try {
      final get = GetIt.instance<GetContinueReading>();
      final list = await get();
      final filtered = list.where((p) => p.mangaId == mangaId).toList();
      if (filtered.isEmpty) return null;
      filtered.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return filtered.first;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleReadFromStart() async {
    final st = context.read<MangaDetailBloc>().state;
    final first = _pickStartChapter(st);
    if (first == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có danh sách chương để đọc.')),
      );
      return;
    }
    _openChapter(first.id.value, pageIndex: 0);
  }

  Future<void> _handleReadContinue() async {
    final st = context.read<MangaDetailBloc>().state;

    // 1) thử lấy progress mới nhất
    final latest = await _getLatestProgressForManga(widget.mangaId);
    if (latest != null) {
      _openChapter(latest.chapterId, pageIndex: latest.pageIndex);
      return;
    }

    // 2) fallback: đọc từ đầu
    final first = _pickStartChapter(st);
    if (first != null) {
      _openChapter(first.id.value, pageIndex: 0);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có chương để đọc.')),
    );
  }

  // ===== UI =====

  Widget _buildHeader(Manga manga) {
    final th = Theme.of(context);
    final tagLine = manga.tags.take(4).join(" • ");

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F0F10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COVER + INFO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- COVER
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 150,
                  child: manga.coverImageUrl != null
                      ? Image.network(
                          manga.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFF2A2A2D),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white38,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // ---- TEXT INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      manga.title,
                      style: th.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (manga.authorName != null)
                      Text(
                        "Tác giả: ${manga.authorName}",
                        style: th.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),

                    if (manga.year != null)
                      Text(
                        "Năm: ${manga.year}",
                        style: th.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),

                    Text(
                      "Trạng thái: ${manga.status}",
                      style: th.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),

                    if (tagLine.isNotEmpty)
                      Text(
                        tagLine,
                        style: th.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---- ACTION ROW (Đọc từ đầu / Đọc tiếp / Tim)
          // Bọc trong SingleChildScrollView ngang để tránh overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilledButton(
                  onPressed: _handleReadFromStart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                    backgroundColor: const Color(0xFF4B3EFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Đọc từ đầu"),
                ),

                const SizedBox(width: 8),

                FilledButton.tonal(
                  onPressed: _handleReadContinue,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text("Đọc tiếp"),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: widget.onToggleFavorite,
                    icon: Icon(
                      manga.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          manga.isFavorite ? Colors.redAccent : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- DESCRIPTION (tối đa 4 dòng)
          if (manga.description != null &&
              manga.description!.trim().isNotEmpty)
            Text(
              manga.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: th.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterSection(
    List<Chapter> chapters,
    bool ascending,
    MangaDetailStatus status,
  ) {
    final bloc = context.read<MangaDetailBloc>();
    final th = Theme.of(context);

    return Container(
      color: const Color(0xFF1A1A1D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Text(
                  "Danh sách chương",
                  style: th.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    bloc.add(const MangaDetailToggleSort());
                  },
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    ascending ? "Asc" : "Desc",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // list chương
          ...chapters.map((c) {
            return ChapterTile(
              chapter: c,
              onTap: () {
                _openChapter(c.id.value, pageIndex: 0);
              },
            );
          }),

          if (status == MangaDetailStatus.loadingMoreChapters)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailBloc, MangaDetailState>(
      builder: (context, state) {
        if (state.status == MangaDetailStatus.loading ||
            state.status == MangaDetailStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == MangaDetailStatus.failure &&
            state.manga == null) {
          return Center(
            child: Text(
              "Lỗi tải truyện.\n${state.errorMessage ?? ''}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        final manga = state.manga!;
        return Container(
          color: const Color(0xFF0F0F10),
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(manga),
                ),
                SliverToBoxAdapter(
                  child: _buildChapterSection(
                    state.chapters,
                    state.ascending,
                    state.status,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
