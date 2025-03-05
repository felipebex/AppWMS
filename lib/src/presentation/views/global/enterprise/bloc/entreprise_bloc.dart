// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/data/entreprice_repository.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/models/recent_url_model.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'entreprise_event.dart';
part 'entreprise_state.dart';

class EntrepriseBloc extends Bloc<EntrepriseEvent, EntrepriseState> {
  final TextEditingController entrepriceController = TextEditingController();

  List<String> entrepriceList = [];
  List<RecentUrl> recentUrls = []; // Lista para almacenar las URLs recientes

  EntrepriceRepository entrepriceRepository = EntrepriceRepository();

  EntrepriseBloc() : super(EntrepriseInitial()) {
    on<LoadUrlFromDB>((event, emit) async {
      try {
        final database = DataBaseSqlite();
        emit(EntrepriseLoading());
        recentUrls = [];
        recentUrls =
            await database.urlsRecientesRepository.getAllUrlsRecientes();
        print(recentUrls.length);
        emit(UpdateListUrls(recentUrls));
      } catch (e, s) {
        print('Error en LoadUrlFromDB: $e $s');
        emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
      }
    });

    add(LoadUrlFromDB());

    on<EntrepriseButtonPressed>((event, emit) async {
      try {
        final database = DataBaseSqlite();
        emit(EntrepriseLoading());

        final session = await entrepriceRepository.searchEnterprice(
          entrepriceController.text,
        );

        if (session.isNotEmpty) {
          Preferences.setUrlWebsite = entrepriceController.text;
          PrefUtils.setEnterprise(
              entrepriceController.text); // Guardar la URL en las preferencias

          // Agregar la URL a la lista de recientes
          await database.urlsRecientesRepository.insertUrlReciente(RecentUrl(
            url: entrepriceController.text,
            fecha: //guardar la fecha en formato 22/09/2021
                DateTime.now().day.toString() +
                    '/' +
                    DateTime.now().month.toString() +
                    '/' +
                    DateTime.now().year.toString(),
          ));

          add(LoadUrlFromDB());
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
        final database = DataBaseSqlite();
        emit(EntrepriseLoading());
        recentUrls.removeAt(event.index);
        await database.urlsRecientesRepository.deleteUrlReciente(event.url);
        emit(UpdateListUrls(recentUrls));
      } catch (e, s) {
        print('Error en DeleteUrl: $e $s');
        emit(EntrepriseFailure('Error en EntrepriseBloc: $e'));
      }
    });
  }
}
