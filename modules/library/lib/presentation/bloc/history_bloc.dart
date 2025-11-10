import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../application/usecases/get_continue_reading.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/library_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetContinueReading _getContinueReading;
  final LibraryRepository _repo;

  HistoryBloc({
    required GetContinueReading getContinueReading,
    required LibraryRepository repo,
  })  : _getContinueReading = getContinueReading,
        _repo = repo,
        super(const HistoryState.initial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryClearAllRequested>(_onClearAllRequested); // NEW
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final list = await _getContinueReading();
      emit(state.copyWith(status: HistoryStatus.success, history: list));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearAllRequested(
    HistoryClearAllRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repo.clearAllProgress();
      final list = await _getContinueReading();
      emit(state.copyWith(status: HistoryStatus.success, history: list));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }
}
