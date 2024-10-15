// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, unnecessary_import, unrelated_type_equality_checks

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_api_module.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'wms_picking_event.dart';
part 'wms_picking_state.dart';

class WMSPickingBloc extends Bloc<PickingEvent, PickingState> {
  //*batchs
  List<BatchsModel> listOfBatchs = [];
  List<BatchsModel> filteredBatchs = []; // Lista para los productos filtrados

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*instancia de la base de datos
  final DataBaseSqlite _databas = DataBaseSqlite();

  WMSPickingBloc() : super(ProductspickingInitial()) {
    //*obtener todos los batchs desde odoo
    on<LoadAllBatchsEvent>(_onLoadAllBatchsEvent);
    //*obtener todos los batchs desde SQLite
    on<LoadBatchsFromDBEvent>(_onLoadBatchsFromDBEvent);
    //*buscar un batch
    on<SearchBatchEvent>(_onSearchBacthEvent);
    //*limpiar la busqueda
    on<ClearSearchBacthEvent>(_onClearSearchEvent);
    //*filtrar por estado los batchs desde SQLite
    on<FilterBatchesBStatusEvent>(_onFilterBatchesBStatusEvent);
  }

  void _onFilterBatchesBStatusEvent(
      FilterBatchesBStatusEvent event, Emitter<PickingState> emit) {
    if (event.status == '') {
      filteredBatchs = listOfBatchs;
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    }
    filteredBatchs =
        listOfBatchs.where((batch) => batch.state == event.status).toList();
    print('filteredBatchs by state: ${filteredBatchs.length}');
    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  void _onLoadAllBatchsEvent(
      LoadAllBatchsEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchsPickingLoadingState());

      final response = await PickingApiModule.resBatchs();
      if (response != null && response is List) {
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            await DataBaseSqlite().insertBatch(
              id: batch.id ?? 0,
              name: batch.name ?? '',
              scheduledDate:
                  batch.scheduledDate ?? 'no scheduled', // Valor predeterminado
              pickingTypeId: batch.pickingTypeId[1] ??
                  '', // Asegúrate de que sea una lista
              state: batch.state,
              userId: batch.userId is bool ? "" : batch.userId[1] ?? '',
            );
          } catch (dbError, stackTrace) {
            print('Error inserting batch: $dbError  $stackTrace');
            // Considera cómo manejar este error (puedes continuar o emitir un estado de error específico)
          }
        }

        add(LoadBatchsFromDBEvent());
        emit(LoadBatchsSuccesState(listOfBatchs: listOfBatchs));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error LoadAllBatchsEvent: $e, $s');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onClearSearchEvent(
      ClearSearchBacthEvent event, Emitter<PickingState> emit) {
    searchController.clear();
    filteredBatchs = listOfBatchs; // Mostrar todos los productos
    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  void _onLoadBatchsFromDBEvent(
      LoadBatchsFromDBEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchsPickingLoadingState());
      final batchsFromDB = await _databas.getAllBatchs();
      filteredBatchs = batchsFromDB;
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
    } catch (e) {
      print('Error loading batchs from DB: $e');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onSearchBacthEvent(SearchBatchEvent event, Emitter<PickingState> emit) {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      filteredBatchs =
          listOfBatchs; // Si la búsqueda está vacía, mostrar todos los productos
    } else {
      filteredBatchs = listOfBatchs.where((batch) {
        return batch.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(LoadBatchsSuccesState(
        listOfBatchs: filteredBatchs)); // Emitir la lista filtrada
  }
}
