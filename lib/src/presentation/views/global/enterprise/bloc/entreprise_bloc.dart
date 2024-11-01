

// ignore_for_file: avoid_print

import 'package:wms_app/src/presentation/views/global/enterprise/data/entreprice_repository.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'entreprise_event.dart';
part 'entreprise_state.dart';

class EntrepriseBloc extends Bloc<EntrepriseEvent, EntrepriseState> {
  final TextEditingController entrepriceController = TextEditingController();

  List<String> entrepriceList = [];
  List<String> recentUrls = []; // Lista para almacenar las URLs recientes


  EntrepriceRepository entrepriceRepository = EntrepriceRepository();

  EntrepriseBloc() : super(EntrepriseInitial()) {
    on<EntrepriseButtonPressed>((event, emit) async {
      try {
        emit(EntrepriseLoading());

        final session = await entrepriceRepository.searchEnterprice(
            entrepriceController.text, );

        print('session: $session');
        
        if (session.isNotEmpty) {
           Preferences.setUrlWebsite = entrepriceController.text;
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

