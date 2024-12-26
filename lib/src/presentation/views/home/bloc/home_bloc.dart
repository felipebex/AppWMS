// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  String userName = "";
  String userEmail = "";
  String userImage = "";
  String userRol = "";

  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadData>((event, emit) async {
      emit(HomeLoadingState());
      try {
        userName = await PrefUtils.getUserName();
        userEmail = await PrefUtils.getUserEmail();
        userRol = await PrefUtils.getUserRol();
        emit(HomeLoadedState());
      } catch (e) {
        emit(HomeLoadErrorState());
      }
    });
    add(HomeLoadData());
  }
}
