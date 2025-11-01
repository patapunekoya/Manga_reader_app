// lib/page/manga_detail_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:catalog/presentation/bloc/manga_detail_bloc.dart';
import 'package:catalog/presentation/widgets/manga_detail_view.dart';



class MangaDetailShellPage extends StatefulWidget {
  final String mangaId;

  const MangaDetailShellPage({
    super.key,
    required this.mangaId,
  });

  @override
  State<MangaDetailShellPage> createState() => _MangaDetailShellPageState();
}

class _MangaDetailShellPageState extends State<MangaDetailShellPage> {
  late final MangaDetailBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = GetIt.instance<MangaDetailBloc>()
      ..add(MangaDetailLoadRequested(widget.mangaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _toggleFavorite() {
    debugPrint("Toggle favorite for manga ${widget.mangaId}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: SafeArea(
        child: Scaffold(
          body: BlocBuilder<MangaDetailBloc, MangaDetailState>(
            builder: (context, state) {
              // giả định state có:
              // - state.chapters: List<Chapter> (hoặc List<ChapterVM>)
              //   mỗi phần tử có ít nhất field id (chapterId)
              //
              // tui cần build ra 1 list<String> chapterIds
              final chapterIds = state.chapters
                  .map((c) => c.id.value) // hoặc c.id nếu đã là String
                  .toList();

              return MangaDetailView(
                mangaId: widget.mangaId,

                onOpenChapter: (String tappedChapterId) {
                  // tìm index của chapter được bấm
                  final idx = chapterIds.indexOf(tappedChapterId);

                  // phòng hờ -1
                  final safeIndex = idx < 0 ? 0 : idx;

                  context.push(
                    "/reader/$tappedChapterId"
                    "?mangaId=${widget.mangaId}&page=0",
                    extra: {
                      "chapters": chapterIds,
                      "currentIndex": safeIndex,
                    },
                  );
                },

                onToggleFavorite: _toggleFavorite,
              );
            },
          ),
        ),
      ),
    );
  }
}
