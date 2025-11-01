// home/domain/entities/home_vm.dart
import 'package:equatable/equatable.dart';

// từ module discovery
import 'package:discovery/domain/entities/feed_item.dart';

// từ module library_manga (mapping ra VM sẵn như bạn làm trước giờ)
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

// Nếu bạn đã có DiscoveryFeedItemVM tương đương với FeedItem,
// bạn có thể giữ dùng FeedItem trực tiếp thay vì VM trung gian.
// Để đơn giản: HomeVM dùng luôn FeedItem.

class HomeVM extends Equatable {
  final List<ContinueReadingItemVM> continueReading; // ngang
  final List<FeedItem> recommended; // carousel (trending)
  final List<FeedItem> latestUpdates; // list dọc

  const HomeVM({
    required this.continueReading,
    required this.recommended,
    required this.latestUpdates,
  });

  @override
  List<Object?> get props => [
        continueReading,
        recommended,
        latestUpdates,
      ];
}
