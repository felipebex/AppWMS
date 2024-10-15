// ignore_for_file: avoid_print

import 'package:wms_app/src/presentation/views/home/data/home_api_module.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  int countBatchDone = 0;
  int countBatchInProgress = 0;
  int countBatchAll = 0;

  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadEvent>(_onHomeLoadEvent);
    add(HomeLoadEvent());
  }

  void _onHomeLoadEvent(HomeLoadEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoadingState());
      countBatchDone = await HomeApiModule.countBatchDone();
      countBatchInProgress = await HomeApiModule.countBatchInProgress();
      countBatchAll = await HomeApiModule.countAllBatch();
      emit(HomeLoadedState());
    } catch (e, s) {
      print('Error _onHomeLoadEvent: $e, $s');
      emit(HomeLoadErrorState());
    }
  }
}
