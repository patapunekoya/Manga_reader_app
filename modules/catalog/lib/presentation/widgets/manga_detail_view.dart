import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// BLoC + domain
import '../bloc/manga_detail_bloc.dart';
import '../../domain/entities/manga.dart';
import '../../domain/entities/chapter.dart';
import 'chapter_tile.dart';

// “Đọc tiếp”
import 'package:library_manga/application/usecases/get_continue_reading.dart';

class MangaDetailView extends StatefulWidget {
  final String mangaId;
  final void Function(String chapterId, {int pageIndex})? onOpenChapter; // pageIndex luôn 0
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

class _MangaDetailViewState extends State<MangaDetailView>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();

  String? _lastReadChapterId;
  bool _progressLoading = true;

  // Toggle mô tả: 4 dòng ↔ full
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<MangaDetailBloc>();
    bloc.add(MangaDetailLoadRequested(widget.mangaId)); // mặc định ASC

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        bloc.add(const MangaDetailLoadMoreChapters());
      }
    });

    _reloadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reloadProgress() async {
    setState(() => _progressLoading = true);
    try {
      final get = GetIt.instance<GetContinueReading>();
      final list = await get();
      final prog = list.where((p) => p.mangaId == widget.mangaId).toList();
      setState(() {
        _lastReadChapterId = prog.isEmpty ? null : prog.first.lastChapterId;
        _progressLoading = false;
      });
    } catch (_) {
      setState(() {
        _lastReadChapterId = null;
        _progressLoading = false;
      });
    }
  }

  Future<void> _openChapter(String chapterId) async {
    if (widget.onOpenChapter != null) {
      widget.onOpenChapter!(chapterId, pageIndex: 0);
      Future.delayed(const Duration(milliseconds: 300), _reloadProgress);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở chương (thiếu onOpenChapter).')),
      );
    }
  }

  Chapter? _pickStartChapter(MangaDetailState st) {
    if (st.chapters.isEmpty) return null;
    return st.ascending ? st.chapters.first : st.chapters.last;
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
    _openChapter(first.id.value);
  }

  Future<void> _handleReadContinue() async {
    final st = context.read<MangaDetailBloc>().state;
    if (_lastReadChapterId != null && _lastReadChapterId!.isNotEmpty) {
      _openChapter(_lastReadChapterId!);
      return;
    }
    final first = _pickStartChapter(st);
    if (first != null) {
      _openChapter(first.id.value);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có chương để đọc.')),
    );
  }

  // --------- DESCRIPTION WITH EXPAND/COLLAPSE ---------
  Widget _buildDescription(String text) {
    // Nếu quá ngắn thì khỏi hiện nút
    final needsExpandButton = text.trim().length > 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          curve: Curves.easeInOut,
          child: Text(
            text,
            maxLines: _descExpanded ? null : 4,
            overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
          ),
        ),
        if (needsExpandButton) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? "Thu gọn" : "Xem thêm",
              style: const TextStyle(
                color: Color(0xFF4B8BFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 150,
                  child: manga.coverImageUrl != null
                      ? Image.network(manga.coverImageUrl!, fit: BoxFit.cover)
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manga.title,
                        style: th.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.2)),
                    const SizedBox(height: 6),
                    if (manga.authorName != null)
                      Text("Tác giả: ${manga.authorName}",
                          style: th.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70, height: 1.3)),
                    if (manga.year != null)
                      Text("Năm: ${manga.year}",
                          style: th.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70, height: 1.3)),
                    Text("Trạng thái: ${manga.status}",
                        style: th.textTheme.bodySmall
                            ?.copyWith(color: Colors.white70, height: 1.3)),
                    if (tagLine.isNotEmpty)
                      Text(tagLine,
                          style: th.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              height: 1.3)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ACTIONS
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
                        borderRadius: BorderRadius.circular(12)),
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
                        borderRadius: BorderRadius.circular(12)),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.w600),
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
                    onPressed: () {
                      context
                          .read<MangaDetailBloc>()
                          .add(const MangaDetailFavoriteToggled());
                    },
                    icon: Icon(
                      manga.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: manga.isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                      size: 22,
                    ),
                    tooltip:
                        manga.isFavorite ? 'Bỏ yêu thích' : 'Thêm yêu thích',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (manga.description != null &&
              manga.description!.trim().isNotEmpty)
            _buildDescription(manga.description!.trim()),
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
    final st = bloc.state;

    final langs = st.availableLanguages; // ví dụ: ['en','vi','id']
    final selected = st.selectedLanguage; // null = All

    // Chỉ hiển thị chapter đúng ngôn ngữ đã chọn
    final visibleChapters = (selected == null)
        ? chapters
        : chapters
            .where((c) =>
                (c.language ?? '').toLowerCase() ==
                selected.toLowerCase())
            .toList();

    return Container(
      color: const Color(0xFF1A1A2D).withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                // SORT
                TextButton.icon(
                  onPressed: () {
                    bloc.add(const MangaDetailToggleSort());
                  },
                  icon: Icon(
                    ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    ascending ? "Asc" : "Desc",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(width: 4),

                // LANGUAGE FILTER
                PopupMenuButton<String?>(
                  tooltip: 'Ngôn ngữ',
                  icon: const Icon(Icons.translate,
                      color: Colors.white, size: 18),
                  onSelected: (value) {
                    // value == null => All
                    bloc.add(MangaDetailSelectLanguage(value));
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String?>>[
                      PopupMenuItem<String?>(
                        value: null,
                        child: Row(
                          children: [
                            if (selected == null)
                              const Icon(Icons.check, size: 16)
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            const Text('All'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 8),
                    ];

                    for (final code in langs) {
                      items.add(
                        PopupMenuItem<String?>(
                          value: code,
                          child: Row(
                            children: [
                              if (selected == code)
                                const Icon(Icons.check, size: 16)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(code.toUpperCase()),
                            ],
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              ],
            ),
          ),

          if (_progressLoading)
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          ...visibleChapters.map((c) {
            final isLastRead = (_lastReadChapterId != null &&
                _lastReadChapterId == c.id.value);
            return ChapterTile(
              chapter: c,
              isRead: isLastRead,
              onTap: () => _openChapter(c.id.value),
            );
          }),

          if (status == MangaDetailStatus.loadingMoreChapters)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
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
                SliverToBoxAdapter(child: _buildHeader(manga)),
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
