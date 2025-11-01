// lib/presentation/bloc/history_state.dart
part of 'history_bloc.dart';

enum HistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ReadingProgress> history;
  final String? errorMessage;

  const HistoryState({
    required this.status,
    required this.history,
    required this.errorMessage,
  });

  const HistoryState.initial()
      : status = HistoryStatus.initial,
        history = const [],
        errorMessage = null;

  HistoryState copyWith({
    HistoryStatus? status,
    List<ReadingProgress>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, errorMessage];
}
