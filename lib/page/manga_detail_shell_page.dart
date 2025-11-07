import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:catalog/presentation/bloc/manga_detail_bloc.dart';
import 'package:catalog/presentation/widgets/manga_detail_view.dart';

class MangaDetailShellPage extends StatefulWidget {
  final String mangaId;
  // Nhận origin từ router: 'home' | 'search' | 'library'
  final String origin;

  const MangaDetailShellPage({
    super.key,
    required this.mangaId,
    required this.origin,
  });

  @override
  State<MangaDetailShellPage> createState() => _MangaDetailShellPageState();
}

class _MangaDetailShellPageState extends State<MangaDetailShellPage> {
  late final MangaDetailBloc _bloc;
  late final String _origin;

  @override
  void initState() {
    super.initState();
    _origin = widget.origin; // không đọc context ở đây nữa
    _bloc = GetIt.instance<MangaDetailBloc>()
      ..add(MangaDetailLoadRequested(widget.mangaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    switch (_origin) {
      case 'search':
        context.go('/search');
        break;
      case 'library':
        context.go('/library');
        break;
      case 'home':
      default:
        context.go('/home');
        break;
    }
  }

  void _toggleFavorite() {
    debugPrint("Toggle favorite for manga ${widget.mangaId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
          tooltip: 'Quay lại',
        ),
        title: BlocBuilder<MangaDetailBloc, MangaDetailState>(
          bloc: _bloc,
          buildWhen: (p, c) => p.manga != c.manga,
          builder: (context, state) {
            final title = state.manga?.title ?? 'Chi tiết truyện';
            return Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<MangaDetailBloc, MangaDetailState>(
            builder: (context, state) {
              final chapterIds = state.chapters.map((c) => c.id.value).toList();
              final chapterNumbers = state.chapters.map((c) => c.chapterNumber).toList();

              final mangaTitle = state.manga?.title ?? '';
              final coverImageUrl = state.manga?.coverImageUrl ?? '';

              return MangaDetailView(
                mangaId: widget.mangaId,
                onOpenChapter: (String tappedChapterId, {int pageIndex = 0}) {
                  final idx = chapterIds.indexOf(tappedChapterId);
                  final safeIndex = idx < 0 ? 0 : idx;

                  context.push(
                    '/reader/$tappedChapterId'
                    '?mangaId=${widget.mangaId}'
                    '&page=$pageIndex'
                    '&mangaTitle=${Uri.encodeComponent(mangaTitle)}'
                    '&coverImageUrl=${Uri.encodeComponent(coverImageUrl)}',
                    extra: {
                      'chapters': chapterIds,
                      'currentIndex': safeIndex,
                      'chapterNumbers': chapterNumbers,
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
