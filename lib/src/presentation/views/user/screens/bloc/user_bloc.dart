// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/data/user_repository.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
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
  String fabricante = '';

  UserBloc() : super(UserInitial()) {
    //*evento para obtener la configuracion de odoo para el usuario y la app
    on<GetConfigurations>((event, emit) async {
      try {
        emit(ConfigurationLoading());
        final response = await userRepository.configurations(event.context);
        if (response != null) {
        final int userId = await PrefUtils.getUserId();
        await db.insertConfiguration(response, userId );
        final Configurations? responsebd = await db.getConfiguration(userId);
          PrefUtils.setUserRol(response.result?.result?.rol ?? '');
          configurations = Configurations();
          configurations = responsebd ?? response;
          await db.insertConfiguration(configurations, userId);
          await db.getConfiguration(userId);
          await PrefUtils.setUserRol(responsebd?.result?.result?.rol ?? '');
          emit(ConfigurationLoaded(responsebd ?? configurations));
        } else {
          emit(ConfigurationError('Error al cargar configuraciones'));
        }
      } catch (e, s) {
        print('Error en GetConfigurations.dart: $e =>$s');
      }
    });
    on<GetConfigurationsUser>((event, emit) async {
      try {
        emit(ConfigurationLoading());
        final response = await userRepository.configurations(event.context);
        if (response != null) {
        final int userId = await PrefUtils.getUserId();
        await db.insertConfiguration(response, userId );
        final Configurations? responsebd = await db.getConfiguration(userId);
          PrefUtils.setUserRol(response.result?.result?.rol ?? '');
          configurations = Configurations();
          configurations = responsebd ?? response;
          await db.insertConfiguration(configurations, userId);
          await db.getConfiguration(userId);
          await PrefUtils.setUserRol(responsebd?.result?.result?.rol ?? '');
          emit(ConfigurationLoadedUser(responsebd ?? configurations));
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
  }

  void _onLoadInfoDeviceEventUser(
      LoadInfoDeviceEventUser event, Emitter<UserState> emit) async {
    emit(UserInitial());
    try {
      //cargamos la informacion del dispositivo
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      modelo = androidInfo.model;
      version = androidInfo.version.release;
      fabricante = androidInfo.manufacturer;
      emit(LoadInfoDeviceStateUser());
    } catch (e, s) {
      print('Error en GetConfigurations.dart: $e =>$s');
    }
  }
}
