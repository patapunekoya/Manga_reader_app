// lib/presentation/bloc/discovery_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../discovery.dart'
    show GetTrending, GetLatestUpdates; // từ barrel
import '../../../domain/entities/feed_item.dart';
import '../../../domain/value_objects/feed_cursor.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// DiscoveryBloc:
/// - Khi app/home screen load, ta bắn DiscoveryLoadEvent()
/// - Bloc gọi 2 usecase:
///     trending = GetTrending(cursor: FeedCursor(offset:0,limit:10))
///     latest   = GetLatestUpdates(cursor: FeedCursor(offset:0,limit:10))
/// - State sẽ giữ trendingList, latestList riêng.
///
/// Có thể mở rộng:
/// - load more trending
/// - load more latest
/// nhưng MVP chỉ cần fetch lần đầu.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetTrending _getTrending;
  final GetLatestUpdates _getLatest;

  DiscoveryBloc({
    required GetTrending getTrending,
    required GetLatestUpdates getLatest,
  })  : _getTrending = getTrending,
        _getLatest = getLatest,
        super(const DiscoveryState.initial()) {
    on<DiscoveryLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(
    DiscoveryLoadEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    // set loading true
    emit(state.copyWith(
      status: DiscoveryStatus.loading,
    ));

    try {
      final trendingItems = await _getTrending(
        cursor: const FeedCursor(offset: 0, limit: 10),
      );
      final latestItems = await _getLatest(
        cursor: const FeedCursor(offset: 0, limit: 10),
      );

      emit(state.copyWith(
        status: DiscoveryStatus.success,
        trending: trendingItems,
        latest: latestItems,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DiscoveryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
