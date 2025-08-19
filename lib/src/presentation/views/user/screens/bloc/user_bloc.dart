// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wms_app/src/core/utils/get_mac_utils.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/data/user_repository.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/user/models/response_pda_register_model.dart';

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
  String mac = '';
  String imei = '';

  List<ResultUbicaciones> ubicaciones = [];
  List<AllowedWarehouse> almacenes = [];

  UserBloc() : super(UserInitial()) {
    //*evento para obtener la configuracion de odoo para el usuario y la app
    on<GetConfigurations>((event, emit) async {
      try {
        emit(ConfigurationLoading());
        final response = await userRepository.configurations(event.context);
        if (response.result?.code == 200) {
          final int userId = await PrefUtils.getUserId();
          await db.configurationsRepository
              .insertConfiguration(response, userId);

          //obtenemos una lista de warehouse de la configuracion
          await db.warehouseRepository.insertAllowedWarehouse(
              response.result?.result?.allowedWarehouses ?? []);

          final Configurations? responsebd =
              await db.configurationsRepository.getConfiguration(userId);
          PrefUtils.setUserRol(response.result?.result?.rol ?? '');
          configurations = Configurations();
          configurations = responsebd ?? response;
          await PrefUtils.setUserRol(responsebd?.result?.result?.rol ?? '');

          almacenes = await db.warehouseRepository.getAllowedWarehouse();
          print("almacenes: ${almacenes.length}");

          emit(ConfigurationLoaded(responsebd ?? configurations));
        } else {
          emit(ConfigurationError(
              response.result?.msg ?? 'Error al cargar configuraciones'));
        }
      } catch (e, s) {
        print('Error en GetConfigurations.dart: $e =>$s');
      }
    });

    //*evento para obtener la informacion del dispositivo
    on<LoadInfoDeviceEventUser>(_onLoadInfoDeviceEventUser);
    add(LoadInfoDeviceEventUser());
    on<GetUbicacionesEvent>(_getUbicacionesEvent);
    //*Evento para registrar el id del dispositivo
    on<RegisterDeviceIdEvent>(_onRegisterDeviceIdEvent);
  }

  void _onRegisterDeviceIdEvent(
      RegisterDeviceIdEvent event, Emitter<UserState> emit) async {
    try {
      emit(RegisterDeviceIdLoading());

      //OBTENER LOS DATOS DEL DISPOSITIVO DESDE EL PREFS
      mac = await PrefUtils.getMacPDA();
      imei = await PrefUtils.getImeiPDA();
      modelo = await PrefUtils.getModeloPDA();
      fabricante = await PrefUtils.getFabricantePDA();

     

      final response = await userRepository.sendIdPda(
          mac == "02:00:00:00:00:00" ? imei : mac,
          modelo,
          "$modelo $fabricante",
          versionApp);

      if (response.result?.code == 200) {
        if (response.result?.data?.isAuthorized == "no") {
          // PrefUtils.setIsLoggedIn(false);
          // PrefUtils.clearUserData();
          emit(RegisterDeviceIdError('Dispositivo no autorizado'));
        } else {
          PrefUtils.setIsLoggedIn(true);
          emit(RegisterDeviceIdSuccess(response));
        }
      } else {
        emit(RegisterDeviceIdError(
            response.result?.msg ?? 'Error al registrar dispositivo'));
      }
    } catch (e, s) {
      print('Error en RegisterDeviceIdEvent.dart: $e =>$s');
      emit(RegisterDeviceIdError('Error al registrar dispositivo'));
    }
  }

  void _getUbicacionesEvent(
      GetUbicacionesEvent event, Emitter<UserState> emit) async {
    emit(UserInitial());
    try {
      emit(GetUbicacionesLoading());
      final response = await userRepository.ubicaciones();
      if (response != null) {
        // filtramos la ubicacion por el almacen
        ubicaciones = response
            .where((ubicacion) =>
                almacenes.any((almacen) => almacen.id == ubicacion.idWarehouse))
            .toList();

        await db.ubicacionesRepository.insertOrUpdateUbicaciones(ubicaciones);

        almacenes = await db.warehouseRepository.getAllowedWarehouse();

        await db.warehouseRepository.insertAllowedWarehouse(almacenes);
        print('ubicaciones: ${response.length}');
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

      mac =
          (await DeviceInfoCustom.getMacAddress()) ?? ''; // mac del dispositivo

      imei = (await DeviceInfoCustom.getImei()) ?? ''; // imei del dispositivo

      idDispositivo = androidInfo
          .id; // Este es el ID único para dispositivos Android // numero de compilacion
      print('idDispositivo: $idDispositivo');
      print('fabricante: $fabricante');
      print('modelo: $modelo');
      print('version: $version');
      print('mac: $mac');
      print('imei: $imei');
      print('versionApp: ${packageInfo.version}');
      versionApp = packageInfo.version; // Versión de la app

      //REGISTRAMOS LOS DATOS DEL DISPOSITIVO
      await PrefUtils.setMacPDA(mac == 'unknown' ? '' : mac);
      await PrefUtils.setImeiPDA(imei == 'unknown' ? '' : imei);
      await PrefUtils.setModeloPDA(modelo);
      await PrefUtils.setFabricantePDA(fabricante);

      almacenes = await db.warehouseRepository.getAllowedWarehouse();

      emit(LoadInfoDeviceStateUser());
    } catch (e, s) {
      print('Error en LoadInfoDeviceEventUser.dart: $e =>$s');
    }
  }
}
