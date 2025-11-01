import 'package:equatable/equatable.dart';

/// View model tổng hợp để Home UI xài
class HomeSection extends Equatable {
  final List<ContinueReadingItemVM> continueReading;
  final List<DiscoveryFeedItemVM> discoveryFeed;

  const HomeSection({
    required this.continueReading,
    required this.discoveryFeed,
  });

  @override
  List<Object?> get props => [
        continueReading,
        discoveryFeed,
      ];
}

/// Card "tiếp tục đọc"
class ContinueReadingItemVM extends Equatable {
  final String mangaId;
  final String mangaTitle;
  final String chapterId;
  final String chapterNumber;
  final int pageIndex;
  final String? coverImageUrl;

  const ContinueReadingItemVM({
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterId,
    required this.chapterNumber,
    required this.pageIndex,
    required this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        mangaId,
        mangaTitle,
        chapterId,
        chapterNumber,
        pageIndex,
        coverImageUrl,
      ];
}

/// Item trong list "Đang hot / Trending"
class DiscoveryFeedItemVM extends Equatable {
  final String mangaId;
  final String title;
  final String? coverImageUrl;
  final String? subLabel;

  const DiscoveryFeedItemVM({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
    required this.subLabel,
  });

  @override
  List<Object?> get props => [
        mangaId,
        title,
        coverImageUrl,
        subLabel,
      ];
}
