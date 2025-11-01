// home/presentation/bloc/home_state.dart
import 'package:equatable/equatable.dart';
import 'package:home/domain/entities/home_vm.dart';
import 'package:discovery/domain/entities/feed_item.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<ContinueReadingItemVM> continueReading;
  final List<FeedItem> recommended;
  final List<FeedItem> latestUpdates;
  final String? errorMessage;

  const HomeState({
    required this.status,
    required this.continueReading,
    required this.recommended,
    required this.latestUpdates,
    required this.errorMessage,
  });

  const HomeState.initial()
      : status = HomeStatus.initial,
        continueReading = const [],
        recommended = const [],
        latestUpdates = const [],
        errorMessage = null;

  HomeState copyWith({
    HomeStatus? status,
    List<ContinueReadingItemVM>? continueReading,
    List<FeedItem>? recommended,
    List<FeedItem>? latestUpdates,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      continueReading: continueReading ?? this.continueReading,
      recommended: recommended ?? this.recommended,
      latestUpdates: latestUpdates ?? this.latestUpdates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        continueReading,
        recommended,
        latestUpdates,
        errorMessage,
      ];
}
