// lib/presentation/bloc/history_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_continue_reading.dart';
import '../../domain/entities/reading_progress.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetContinueReading _getContinueReading;

  HistoryBloc({
    required GetContinueReading getContinueReading,
  })  : _getContinueReading = getContinueReading,
        super(const HistoryState.initial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final list = await _getContinueReading();
      emit(state.copyWith(
        status: HistoryStatus.success,
        history: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
