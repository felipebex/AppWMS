// // ignore_for_file: avoid_print

// import 'package:bexwmsapp/src/presentation/providers/db/database.dart';
// import 'package:bexwmsapp/src/presentation/views/global/enterprise/data/entreprice_api_module.dart';
// import 'package:bexwmsapp/src/presentation/views/global/enterprise/models/recent_url_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';

// part 'entreprise_event.dart';
// part 'entreprise_state.dart';

// class EntrepriseBloc extends Bloc<EntrepriseEvent, EntrepriseState> {
//   final TextEditingController entrepriceController = TextEditingController();

//   List<String> entrepriceList = [];
//   List<RecentUrl> recentUrls = []; // Lista para almacenar las URLs recientes
//   String method = "https://";
//   final DataBaseSqlite _databas = DataBaseSqlite();

//   EntrepriseBloc() : super(EntrepriseInitial()) {
//     on<LoadUrlFromDB>((event, emit) async {
//       try {
//         // await _databas.deleteAllUrlsRecientes();
//         emit(EntrepriseLoading());
//         recentUrls = [];
//         recentUrls = await _databas.getAllUrlsRecientes();
//         print(recentUrls.length);
//         emit(UpdateListUrls(recentUrls));
//       } catch (e, s) {
//         print('Error en LoadUrlFromDB: $e $s');
//         emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
//       }
//     });

//     add(LoadUrlFromDB());

//     on<ChangeMethod>((event, emit) async {
//       try {
//         emit(EntrepriseLoading());
//         method = event.method;
//         emit(UpdateMethod(method));
//       } catch (e, s) {
//         print('Error en ChangeMethod: $e $s');
//         emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
//       }
//     });

//     on<EntrepriseButtonPressed>((event, emit) async {
//       try {
//         add(LoadUrlFromDB());
//         emit(EntrepriseLoading());
//         entrepriceList = [];
//         final session =
//             await EntrepriceApiModule.searchEnterprice(event.entreprice);
//         if (session.isNotEmpty) {
//           // Validar que la URL no esté ya en recentUrls
//           String currentUrl = entrepriceController.text.trim();
//           if (recentUrls.any((element) =>
//               element.url == currentUrl && element.method == method)) {
//           } else {
//             await _databas.insertUrlReciente(
//                 currentUrl, method); // Guardar la lista en la base de datos
//             emit(UpdateListUrls(
//                 recentUrls)); // Emitir el nuevo estado con la lista actualizada
//           }

//           // Usar una lista temporal
//           List<String> tempList = [];
//           for (var element in session) {
//             tempList.add(element);
//           }
//           entrepriceList = tempList; // Reemplazar la lista original
//           emit(EntrepriseSuccess());
//         } else {
//           emit(EntrepriseFailure(
//               "No se encontraron resultados para esta empresa"));
//         }
//       } catch (e, s) {
//         print('Error en EntrepriseButtonPressed: $e $s');
//         emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
//       }
//     });

//     on<DeleteUrl>((event, emit) async {
//       try {
//         emit(EntrepriseLoading());
//         await _databas.deleteUrlReciente(event.url, event.method);
//         recentUrls = await _databas.getAllUrlsRecientes();
//         emit(UpdateListUrls(recentUrls));
//       } catch (e, s) {
//         print('Error en DeleteUrl: $e $s');
//         emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
//       }
//     });
//   }
// }


// ignore_for_file: unnecessary_import, avoid_print

import 'package:wms_app/src/presentation/views/global/enterprise/data/entreprice_api_module.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'entreprise_event.dart';
part 'entreprise_state.dart';

class EntrepriseBloc extends Bloc<EntrepriseEvent, EntrepriseState> {
  final TextEditingController entrepriceController = TextEditingController();

  List<String> entrepriceList = [];
  List<String> recentUrls = []; // Lista para almacenar las URLs recientes


  EntrepriseBloc() : super(EntrepriseInitial()) {
    on<EntrepriseButtonPressed>((event, emit) async {
      try {
        emit(EntrepriseLoading());

        final session = await EntrepriceApiModule.searchEnterprice(
            entrepriceController.text, );
        if (session.isNotEmpty) {
          
           PrefUtils.setEnterprise(entrepriceController.text); // Guardar la URL en las preferencias

          recentUrls.add(entrepriceController.text); // Agregar la URL a la lista de recientes
          // Usar una lista temporal
          List<String> tempList = [];
          for (var element in session) {
            
            tempList.add(element);
          }
          entrepriceList = tempList; // Reemplazar la lista original
          emit(EntrepriseSuccess());
        } else {
          emit(EntrepriseFailure(
              "No se encontraron resultados para esta empresa"));
        }
      } catch (e, s) {
        print('Error en EntrepriseButtonPressed: $e $s');
        emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
      }
    });


    on<DeleteUrl>((event, emit) async {
      try {
        emit(EntrepriseLoading());
        recentUrls.removeAt(event.index);
        emit(UpdateListUrls(recentUrls));
      } catch (e, s) {
        print('Error en DeleteUrl: $e $s');
        emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
      }
    });

  }




}

