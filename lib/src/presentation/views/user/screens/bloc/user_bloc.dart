// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/data/user_repository.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';

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
        emit(ConfigurationLoading());
        final response = await userRepository.configurations();
        if(response !=null ){
          configurations = Configurations();
          configurations = response;

          await db.insertConfiguration(configurations, configurations.data?.result?.id??0);
          emit(ConfigurationLoaded(configurations));
        }else{
          emit(ConfigurationError('Error al cargar configuraciones'));
        }
      } catch (e, s) {
        print('Error en GetConfigurations.dart: $e =>$s');
      }
    });
  }
}
