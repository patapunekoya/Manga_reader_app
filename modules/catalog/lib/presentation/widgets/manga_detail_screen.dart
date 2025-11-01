import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/manga_detail_bloc.dart';


class MangaDetailScreen extends StatelessWidget {
  final String mangaId;
  const MangaDetailScreen({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => // GetIt.resolve<MangaDetailBloc>() ..add(LoadMangaDetail(mangaId)),
          throw UnimplementedError(), // bạn sẽ nối GetIt vào đây
      child: BlocBuilder<MangaDetailBloc, MangaDetailState>(
        builder: (context, state) {
          // loading
          // error
          // success
          // ... tương tự như bạn đã làm

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
          return const Center(child: Text('TODO detail UI'));
        },
      ),
    );
  }
}
