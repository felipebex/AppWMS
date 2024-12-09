// // ignore_for_file: unnecessary_null_comparison, avoid_print

// import 'dart:io';

// import 'package:bloc/bloc.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:meta/meta.dart';
// import 'package:wms_app/src/presentation/providers/db/database.dart';
// import 'package:wms_app/src/presentation/views/user/data/user_repository.dart';
// import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
// import 'package:wms_app/src/utils/prefs/pref_utils.dart';

// part 'user_event.dart';
// part 'user_state.dart';

// class UserBloc extends Bloc<UserEvent, UserState> {
//   UserRepository userRepository = UserRepository();

//   //*configuraciones
//   Configurations configurations = Configurations();

//   //*instancia de la base de datos
//   final DataBaseSqlite db = DataBaseSqlite();

//   UserBloc() : super(UserInitial()) {
//     on<GetConfigurations>((event, emit) async {
//       try {
//         //validamos que tenga internet

//         final int userId = await PrefUtils.getUserId();
//         emit(ConfigurationLoading());
//         final response = await userRepository.configurations();
//         if (response != null) {
//           configurations = Configurations();
//           configurations = response;

//           await db.insertConfiguration(configurations, userId);
//           // add(GetConfigurationsFromDB());
//           emit(ConfigurationLoaded(configurations));
//         } else {
//           emit(ConfigurationError('Error al cargar configuraciones'));
//         }
//       } catch (e, s) {
//         // add(GetConfigurationsFromDB());
//         print('Error en GetConfigurations.dart: $e =>$s');
//       }
//     });

//     on<GetConfigurationsFromDB>((event, emit) async {
//       try {
//         emit(ConfigurationLoading());
//         final int userId = await PrefUtils.getUserId();
//         print('userId: $userId');
//         configurations = await db.getConfiguration(userId);
//         print('configurations: $configurations');
//         if (configurations != null) {
//           emit(ConfigurationLoaded(configurations));
//         } else {
//           emit(ConfigurationError('Error al cargar configuraciones'));
//         }
//       } catch (e, s) {
//         print('Error en GetConfigurationsFromDB.dart: $e =>$s');
//       }
//     });
//   }
// }

// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
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

  UserBloc() : super(UserInitial()) {
    on<GetConfigurations>((event, emit) async {
      try {
        print('GetConfigurations');
        emit(ConfigurationLoading());
        final response = await userRepository.configurations(event.context);
        int userId = await PrefUtils.getUserId();
        await db.insertConfiguration(response, userId);
        final Configurations? responsebd = await db.getConfiguration(userId);

        if (response != null) {
          configurations = Configurations();
          configurations = responsebd ?? response;

          //cargamos el id del usuario
          int userId = await PrefUtils.getUserId();

          await db.insertConfiguration(configurations, userId);
          await db.getConfiguration(userId);

          print(configurations);
          //actualizamos el rol
          await PrefUtils.setUserRol(responsebd?.data?.result?.rol ?? '');

          emit(ConfigurationLoaded(responsebd ?? configurations));
        } else {
          emit(ConfigurationError('Error al cargar configuraciones'));
        }
      } catch (e, s) {
        print('Error en GetConfigurations.dart: $e =>$s');
      }
    });
  }
}
