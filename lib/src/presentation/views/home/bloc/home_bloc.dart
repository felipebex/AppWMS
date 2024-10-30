// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/home/data/home_api_module.dart';
import 'package:bloc/bloc.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  int countBatchDone = 0;
  int countBatchInProgress = 0;
  int countBatchAll = 0;

  final BuildContext context;
  HomeBloc(
    this.context,
  ) : super(HomeInitial()) {
    on<HomeLoadEvent>(_onHomeLoadEvent);
    add(HomeLoadEvent(
      context,
    ));
  }

  void _onHomeLoadEvent(HomeLoadEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoadingState());
      countBatchDone = await HomeApiModule.countBatchDone(
        event.context,
      );
      countBatchInProgress = await HomeApiModule.countBatchInProgress(
        event.context,
      );
      countBatchAll = await HomeApiModule.countAllBatch(
        event.context,
      );  
      emit(HomeLoadedState());
    } catch (e, s) {
      print('Error _onHomeLoadEvent: $e, $s');
      emit(HomeLoadErrorState());
    }
  }
}
