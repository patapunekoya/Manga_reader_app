// lib/presentation/widgets/search_view.dart
//
// PURPOSE
// - Màn hình Search: nhập từ khóa + lọc theo thể loại, hiển thị kết quả dạng Grid,
//   hỗ trợ phân trang (infinite scroll) và debounce khi gõ.
// - Không tự điều hướng; nhận callback onTapManga để router/shell xử lý.
//
// KIẾN TRÚC & LUỒNG DỮ LIỆU
// - UI phát sự kiện vào SearchBloc:
//    • SearchStarted(query, genre) khi người dùng gõ hoặc đổi thể loại.
//    • SearchLoadMore khi kéo gần cuối danh sách.
// - Bloc giữ state: query hiện tại, genre hiện tại (nullable = All), items, offset, hasMore, status.
// - Debounce 400ms cho text input để giảm số lần gọi API.
// - Lần mở trang đầu tiên: tự fire SearchStarted('', null) để hiển thị "All".
//
// THÀNH PHẦN CHÍNH
// 1) Thanh search + nút clear: nhập query, debounce, giữ nguyên genre hiện tại.
// 2) Dropdown thể loại: 'All' → NULL genre để repo không lọc; còn lại pass đúng genre.
// 3) Status mini: hiển thị Loading… / số kết quả / lỗi mạng / không có kết quả.
// 4) Grid kết quả: MangaCard; itemCount += 1 khi đang loadingMore để render spinner cuối grid.
// 5) Infinite scroll: khi còn cách đáy ~200px → phát SearchLoadMore.
//
// LƯU Ý
// - Không tự đóng/mở BLoC ở đây; Bloc được cung cấp từ trang Shell (SearchShellPage).
// - Không thay đổi code logic; chỉ bổ sung chú thích giải thích.

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
  // Controller cho ô nhập và Grid
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  // Debounce typing
  Timer? _debounce;

  // Danh sách thể loại (hard-code). Sau có thể map sang Tag của MangaDex.
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

    // Fire initial search để có state "All" ngay khi mở trang
    Future.microtask(() {
      context.read<SearchBloc>().add(const SearchStarted(query: '', genre: null));
    });

    // Infinite scroll: khi gần chạm đáy 200px → load thêm
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

  // Khi user gõ: debounce 400ms rồi phát SearchStarted, giữ nguyên genre hiện tại
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

  // Khi đổi thể loại: 'All' → null (bỏ lọc), còn lại giữ nguyên query hiện tại
  void _onGenreChanged(String newGenre, SearchState currentState) {
    final genreParam = (newGenre == 'All') ? null : newGenre;

    context.read<SearchBloc>().add(
          SearchStarted(
            query: currentState.query,
            genre: genreParam,
          ),
        );
  }

  // Nút clear query: xóa text và fire search rỗng với genre hiện tại
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
            // Giá trị dropdown hiển thị: null → 'All', còn lại in ra genre hiện tại
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
                            // Gọi _onQueryChanged để debounce và phát event
                            onChanged: (val) => _onQueryChanged(val, state),
                          ),
                        ),

                        // Nút clear chỉ hiện khi có text
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
                      // Dropdown genre: map chuỗi label → giá trị gửi lên Bloc
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

                      // Status mini: Loading… / lỗi / số kết quả / không có kết quả
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
                // Body render theo state (initial/loading/failure/success)
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

  // Quyết định nội dung body theo SearchState
  Widget _buildBodyByState(
    SearchState state, {
    required ScrollController scrollController,
  }) {
    // Gợi ý ban đầu
    if (state.status == SearchStatus.initial) {
      return const _EmptyHint(text: "Nhập tên truyện hoặc chọn thể loại để tìm.");
    }

    // Đang loading trang đầu
    if (state.status == SearchStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lỗi khi chưa có item nào
    if (state.status == SearchStatus.failure && state.items.isEmpty) {
      return _EmptyHint(text: "Không tìm thấy hoặc lỗi mạng.\n${state.errorMessage ?? ''}");
    }

    // Thành công nhưng rỗng
    if (state.status == SearchStatus.success && state.items.isEmpty) {
      return const _EmptyHint(text: "Không có kết quả");
    }

    // Có kết quả: hiển thị Grid + spinner ô cuối nếu đang loadMore
    return _ResultGrid(
      scrollController: scrollController,
      items: state.items,
      loadingMore: state.status == SearchStatus.loadingMore,
      onTapManga: widget.onTapManga,
    );
  }
}

// ===================================================================
// TIỂU PHẦN UI: Status mini bên cạnh dropdown thể loại
// - Loading / LoadingMore: spinner + text
// - Failure: “Lỗi mạng” (đỏ)
// - Success + rỗng có tiêu chí: “Không có kết quả”
// - Success + có items: “N kết quả”
// ===================================================================
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

    // không có kết quả (đã có tiêu chí tìm)
    if (state.items.isEmpty &&
        state.status == SearchStatus.success &&
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

// ===================================================================
// TIỂU PHẦN UI: Lưới kết quả
// - childAspectRatio 0.55 để MangaCard thoải mái chiều cao (khớp layout card).
// - Khi loadingMore: thêm 1 ô spinner ở cuối.
// - onTapManga: forward id ra ngoài để shell điều hướng.
// ===================================================================
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
        // Ô cuối là spinner khi loadingMore
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

// ===================================================================
// TIỂU PHẦN UI: Hint rỗng
// ===================================================================
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
