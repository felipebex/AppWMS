// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wms_app/src/presentation/views/home/data/home_repository.dart';
import 'package:wms_app/src/presentation/views/home/domain/models/app_version_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  String userName = "";
  String userEmail = "";
  String userImage = "";
  String userRol = "";

  String versionApp = "";

  AppVersion appVersion = AppVersion();

  HomeRepository homeRepository = HomeRepository();

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

    on<AppVersionEvent>((event, emit) async {
      emit(AppVersionLoadingState());
      try {
        final response = await homeRepository.getAppVersion(event.context);
        if(response.result == null) {
          emit(AppVersionLoadErrorState('Error al obtener la versión de la app'));
          return;
        }
        appVersion = response;
        //obtenemos la versión de la app
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version; // Versión de la app
        // String buildNumber = packageInfo.buildNumber; // Número del build
        //validamos si las versiones son diferentes
        if (version == appVersion.result?.result?.version) {
          emit(AppVersionLoadedState(appVersion));
        } else {
          emit(AppVersionUpdateState(appVersion));
        }
      } catch (e) {
        emit(
            AppVersionLoadErrorState('Error al obtener la versión de la app '));
      }
    });
  }
}
