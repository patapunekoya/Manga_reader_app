import 'dart:async';
import 'package:flutter/material.dart';
import 'package:discovery/domain/entities/feed_item.dart';

class RecommendedCarousel extends StatefulWidget {
  final List<FeedItem> items;
  final void Function(String mangaId) onTapManga;

  const RecommendedCarousel({
    super.key,
    required this.items,
    required this.onTapManga,
  });

  @override
  State<RecommendedCarousel> createState() => _RecommendedCarouselState();
}

class _RecommendedCarouselState extends State<RecommendedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (widget.items.isEmpty) return;
        _current = (_current + 1) % widget.items.length;
        _pageController.animateToPage(
          _current,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final it = widget.items[index];
          return GestureDetector(
            onTap: () => widget.onTapManga(it.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1D),
                borderRadius: BorderRadius.circular(16),
                image: it.coverImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(it.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
