// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ulid/ulid.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/data/user_repository.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository userRepository = UserRepository();

  //*configuraciones
  Configurations configurations = Configurations();

  //*instancia de la base de datos
  final DataBaseSqlite db = DataBaseSqlite();

  //*Datos de dive
  String modelo = '';
  String version = '';
  String versionApp = '';
  String fabricante = '';
  String idDispositivo = '';

  List<ResultUbicaciones> ubicaciones = [];

  UserBloc() : super(UserInitial()) {
    //*evento para obtener la configuracion de odoo para el usuario y la app
    on<GetConfigurations>((event, emit) async {
      try {
        emit(ConfigurationLoading());
        final response = await userRepository.configurations(event.context);
        if (response != null) {
          final int userId = await PrefUtils.getUserId();
          await db.configurationsRepository
              .insertConfiguration(response, userId);
          final Configurations? responsebd =
              await db.configurationsRepository.getConfiguration(userId);
          PrefUtils.setUserRol(response.result?.result?.rol ?? '');
          configurations = Configurations();
          configurations = responsebd ?? response;
          await PrefUtils.setUserRol(responsebd?.result?.result?.rol ?? '');
          emit(ConfigurationLoaded(responsebd ?? configurations));
        } else {
          emit(ConfigurationError('Error al cargar configuraciones'));
        }
      } catch (e, s) {
        print('Error en GetConfigurations.dart: $e =>$s');
      }
    });

    //*evento para obtener la informacion del dispositivo
    on<LoadInfoDeviceEventUser>(_onLoadInfoDeviceEventUser);
    add(LoadInfoDeviceEventUser());
    on<GetUbicacionesEvent>(_getUbicacionesEvent);
  }

  void _getUbicacionesEvent(
      GetUbicacionesEvent event, Emitter<UserState> emit) async {
    emit(UserInitial());
    try {
      emit(GetUbicacionesLoading());
      final response = await userRepository.ubicaciones();
      if (response != null) {
        print('ubicaciones: ${response.length}');
        await db.ubicacionesRepository.insertOrUpdateUbicaciones(response);
        ubicaciones = response;
        emit(GetUbicacionesLoaded(response));
      } else {
        emit(GetUbicacionesError('Error al cargar ubicaciones'));
      }
    } catch (e, s) {
      print('Error en GetUbicacionesEvent.dart: $e =>$s');
    }
  }

  void _onLoadInfoDeviceEventUser(
      LoadInfoDeviceEventUser event, Emitter<UserState> emit) async {
    emit(UserInitial());
    try {
      //cargamos la informacion del dispositivo
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      modelo = androidInfo.model;
      version = androidInfo.version.release;
      fabricante = androidInfo.manufacturer;


      print('idDispositivo:  ${Ulid().toUuid()}');

      // idDispositivo =
      //     androidInfo.id; // Este es el ID único para dispositivos Android
      // print('idDispositivo: $idDispositivo');

      versionApp = packageInfo.version; // Versión de la app
      emit(LoadInfoDeviceStateUser());
    } catch (e, s) {
      print('Error en LoadInfoDeviceEventUser.dart: $e =>$s');
    }
  }
}
