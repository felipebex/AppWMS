// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/home/data/home_repository.dart';
import 'package:wms_app/src/presentation/views/home/domain/models/app_version_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
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

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  DataBaseSqlite db = DataBaseSqlite();

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

    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserHome>(_onLoadConfigurationsUserEvent);

    on<AppVersionEvent>((event, emit) async {
      emit(AppVersionLoadingState());
      try {
        final response = await homeRepository.getAppVersion();
        if (response.result == null) {
          emit(AppVersionLoadErrorState(
              'Error al obtener la versión de la app'));
          return;
        }
        appVersion = response;
        // Obtenemos la versión de la app
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version; // Versión de la app

        // Comparamos las versiones
        String currentVersion = appVersion.result?.result?.version ?? '';

        if (version == currentVersion) {
          // Si las versiones son iguales, la app está actualizada
          print('La app está actualizada: $version');
          emit(AppVersionLoadedState(appVersion));
        } else if (version.compareTo(currentVersion) > 0) {
          // Si la versión local es mayor (es decir, está más actualizada)
          print('La app está más actualizada: $version');
          emit(AppVersionLoadedState(appVersion)); // Ya está actualizada
        } else if (version.compareTo(currentVersion) < 0) {
          print('Hay una actualización disponible: $version');
          // Si la versión local es menor, hay una actualización disponible
          emit(AppVersionUpdateState(appVersion));
        }
      } catch (e) {
        emit(
            AppVersionLoadErrorState('Error al obtener la versión de la app '));
      }
    });
  }

  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserHome event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);
      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedHomeState(response));
      } else {
        emit(ConfigurationErrorHomeState('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorHomeState(e.toString()));
      print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    }
  }
}
