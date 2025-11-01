// lib/presentation/widgets/search_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/manga.dart';
import '../bloc/search_bloc.dart';
import 'manga_card.dart';

class SearchView extends StatefulWidget {
  final void Function(String mangaId)? onTapManga;
  const SearchView({
    super.key,
    this.onTapManga,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  // debounce cho text search
  Timer? _debounce;

  // list thể loại tạm thời hard-code, sau này có thể lấy từ API tag của MangaDex
  final List<String> _genres = const [
    'All',
    'Action',
    'Romance',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Sci-Fi',
  ];

  @override
  void initState() {
    super.initState();

    // infinite scroll
    _scrollController.addListener(() {
      final bloc = context.read<SearchBloc>();
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        bloc.add(const SearchLoadMore());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Khi user gõ text
  void _onQueryChanged(String value, SearchState currentState) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>().add(
            SearchStarted(
              query: value,
              genre: currentState.genre, // giữ thể loại hiện tại
            ),
          );
    });
  }

  // Khi user đổi thể loại
  void _onGenreChanged(String newGenre, SearchState currentState) {
    // cập nhật search dựa trên query hiện tại + thể loại mới
    final genreParam = (newGenre == 'All') ? null : newGenre;

    context.read<SearchBloc>().add(
          SearchStarted(
            query: currentState.query,
            genre: genreParam,
          ),
        );
  }

  // nút clear text
  void _clearQuery(SearchState currentState) {
    _controller.clear();
    context.read<SearchBloc>().add(
          SearchStarted(
            query: '',
            genre: currentState.genre,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Container(
      color: const Color(0xFF0F0F10),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            // để tiện tính dropdown value
            final dropdownValue = state.genre == null ? 'All' : state.genre!;

            return Column(
              children: [
                // ===== THANH SEARCH + CLEAR =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white10,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: th.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: "Search manga...",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) => _onQueryChanged(val, state),
                          ),
                        ),

                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => _clearQuery(state),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.white38,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ===== HÀNG THỂ LOẠI + STATUS MINI =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      // Dropdown genre
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            borderRadius: BorderRadius.circular(10),
                            dropdownColor: const Color(0xFF1A1A1D),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            items: _genres.map((g) {
                              return DropdownMenuItem<String>(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                        g == dropdownValue ? 1.0 : 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              _onGenreChanged(val, state);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // status mini: "Loading...", "12 kết quả", "Lỗi mạng", ...
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadgeMini(state: state),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== GRID KẾT QUẢ =====
                Expanded(
                  child: _buildBodyByState(
                    state,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyByState(
    SearchState state, {
    required ScrollController scrollController,
  }) {
    // trạng thái ban đầu
    final noCriteria =
        state.query.isEmpty && (state.genre == null || state.genre!.isEmpty);

    if (state.status == SearchStatus.initial || noCriteria) {
      return const _EmptyHint(
        text: "Nhập tên truyện hoặc chọn thể loại để tìm.",
      );
    }

    // đang load lần đầu
    if (state.status == SearchStatus.loading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // lỗi khi chưa có data
    if (state.status == SearchStatus.failure && state.items.isEmpty) {
      return _EmptyHint(
        text:
            "Không tìm thấy hoặc lỗi mạng.\n${state.errorMessage ?? ''}",
      );
    }

    // có data rồi (kể cả đang loadMore)
    return _ResultGrid(
      scrollController: scrollController,
      items: state.items,
      loadingMore: state.status == SearchStatus.loadingMore,
      onTapManga: widget.onTapManga,
    );
  }
}

class _StatusBadgeMini extends StatelessWidget {
  final SearchState state;
  const _StatusBadgeMini({required this.state});

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      color: Colors.white60,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.2,
    );

    // loading / loadingMore
    if (state.status == SearchStatus.loading ||
        state.status == SearchStatus.loadingMore) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(width: 6),
          Text("Loading...", style: baseStyle),
        ],
      );
    }

    // lỗi
    if (state.status == SearchStatus.failure &&
        state.errorMessage != null &&
        state.errorMessage!.isNotEmpty) {
      return Text(
        "Lỗi mạng",
        style: baseStyle.copyWith(color: Colors.redAccent),
        overflow: TextOverflow.ellipsis,
      );
    }

    // không có kết quả
    if (state.items.isEmpty &&
        state.status == SearchStatus.success &&
        // có tiêu chí tìm, mà vẫn rỗng
        (!state.query.isEmpty || state.genre != null)) {
      return Text(
        "Không có kết quả",
        style: baseStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    // có kết quả
    if (state.items.isNotEmpty) {
      return Text(
        "${state.items.length} kết quả",
        style: baseStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const SizedBox.shrink();
  }
}

class _ResultGrid extends StatelessWidget {
  final ScrollController scrollController;
  final List<Manga> items;
  final bool loadingMore;
  final void Function(String mangaId)? onTapManga;

  const _ResultGrid({
    required this.scrollController,
    required this.items,
    required this.loadingMore,
    required this.onTapManga,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // đủ cao để MangaCard không overflow
        childAspectRatio: 0.55,
      ),
      itemCount: items.length + (loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final manga = items[index];
        return MangaCard(
          manga: manga,
          onTap: () {
            if (onTapManga != null) {
              onTapManga!(manga.id.value);
            }
          },
        );
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
