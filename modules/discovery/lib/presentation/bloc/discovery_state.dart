// lib/presentation/bloc/discovery_state.dart

part of 'discovery_bloc.dart';

/// Trạng thái tổng thể cho DiscoveryBloc.
/// Ta chia status theo enum:
/// - initial: chưa load
/// - loading: đang fetch
/// - success: có data
/// - failure: lỗi
enum DiscoveryStatus { initial, loading, success, failure }

class DiscoveryState extends Equatable {
  final DiscoveryStatus status;
  final List<FeedItem> trending;
  final List<FeedItem> latest;
  final String? errorMessage;

  const DiscoveryState({
    required this.status,
    required this.trending,
    required this.latest,
    required this.errorMessage,
  });

  const DiscoveryState.initial()
      : status = DiscoveryStatus.initial,
        trending = const [],
        latest = const [],
        errorMessage = null;

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<FeedItem>? trending,
    List<FeedItem>? latest,
    String? errorMessage,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      trending: trending ?? this.trending,
      latest: latest ?? this.latest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        trending,
        latest,
        errorMessage,
      ];
}
