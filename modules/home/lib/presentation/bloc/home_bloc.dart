// home/presentation/bloc/home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'home_event.dart';
import 'home_state.dart';

import 'package:home/application/usecases/build_home_vm.dart';
import 'package:home/domain/entities/home_vm.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BuildHomeVM _buildHomeVM;

  HomeBloc({
    required BuildHomeVM buildHomeVM,
  })  : _buildHomeVM = buildHomeVM,
        super(const HomeState.initial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final HomeVM vm = await _buildHomeVM();

      emit(
        state.copyWith(
          status: HomeStatus.success,
          continueReading: vm.continueReading,
          recommended: vm.recommended,
          latestUpdates: vm.latestUpdates,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
