// lib/presentation/bloc/history_event.dart
part of 'history_bloc.dart';

@immutable
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}
