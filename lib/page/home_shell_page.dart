import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

import 'package:home/presentation/bloc/home_bloc.dart';
import 'package:home/presentation/bloc/home_event.dart';
import 'package:home/presentation/bloc/home_state.dart';

// widgets mới
import 'package:home/presentation/widgets/recommended_carousel.dart';
import 'package:home/presentation/widgets/latest_updates_list.dart';
import 'package:home/presentation/widgets/continue_reading_strip.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = GetIt.instance<HomeBloc>()
      ..add(const HomeLoadRequested());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  void _openReaderFromContinue({
    required String mangaId,
    required String chapterId,
    required int pageIndex,
  }) {
    context.push(
      "/reader/$chapterId?mangaId=$mangaId&page=$pageIndex",
    );
  }

  void _openMangaDetail(String mangaId) {
    context.push("/manga/$mangaId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocProvider.value(
          value: _homeBloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final isLoading = state.status == HomeStatus.loading ||
                  state.status == HomeStatus.initial;
              final isError = state.status == HomeStatus.failure;

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (isError) {
                return Center(
                  child: Text(
                    state.errorMessage ?? "Lỗi tải dữ liệu",
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Recommended Carousel =====
                    const Text(
                      "Recommended for you",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    RecommendedCarousel(
                      items: state.recommended,
                      onTapManga: _openMangaDetail,
                    ),

                    const SizedBox(height: 24),

                    // ===== Latest Updates (list dọc) =====
                    const Text(
                      "Latest Updates",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    LatestUpdatesList(
                      items: state.latestUpdates,
                      onTapManga: _openMangaDetail,
                    ),

                    const SizedBox(height: 24),

                    // ===== Continue Reading (ngang) =====
                    const Text(
                      "Đang đọc dở",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ContinueReadingStrip(
                      items: state.continueReading,
                      onTapContinue: ({
                        required String mangaId,
                        required String chapterId,
                        required int pageIndex,
                      }) {
                        _openReaderFromContinue(
                          mangaId: mangaId,
                          chapterId: chapterId,
                          pageIndex: pageIndex,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
