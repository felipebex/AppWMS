// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, unnecessary_import, unrelated_type_equality_checks, use_build_context_synchronously

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_piicking_rerpository.dart';
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
  List<BatchsModel> batchsDone = []; // Lista para los productos filtrados

  WmsPickingRepository wmsPickingRepository = WmsPickingRepository();

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*instancia de la base de datos
  final DataBaseSqlite _databas = DataBaseSqlite();

  WMSPickingBloc() : super(ProductspickingInitial()) {
    //*obtener todos los batchs desde odoox
    on<LoadAllBatchsEvent>(_onLoadAllBatchsEvent);
    //*obtener todos los batchs desde SQLite
    on<LoadBatchsFromDBEvent>(_onLoadBatchsFromDBEvent);
    //*buscar un batch
    on<SearchBatchEvent>(_onSearchBacthEvent);
    //*filtrar por estado los batchs desde SQLite
    on<FilterBatchesBStatusEvent>(_onFilterBatchesBStatusEvent);

    //* filtrar por tipo de operacion
    on<FilterBatchesByOperationTypeEvent>(_onFilterBatchesByOperationTypeEvent);

    //* filtrar por tipo de batch o wave
    on<FilterBatchesByTypeEvent>(_onFilterBatchesByTypeEvent);
  }

  void _onFilterBatchesByTypeEvent(
      FilterBatchesByTypeEvent event, Emitter<PickingState> emit) {
    String status = '';

    add(LoadBatchsFromDBEvent());

    if (event.indexMenu == 0) {
      filteredBatchs = listOfBatchs.where((batch) {
        return batch.isWave.toString() == event.isWave;
      }).toList();
    } else {
      switch (event.indexMenu) {
        case 1:
          status = 'in_progress';
          filteredBatchs = listOfBatchs.where((batch) {
            return batch.isSeparate == status;
          }).toList();
          break;
        case 2:
          status = 'done';
          filteredBatchs = listOfBatchs.where((batch) {
            return batch.isSeparate == 1;
          }).toList();
          break;
      }

      filteredBatchs = listOfBatchs.where((batch) {
        // Comprueba si isWave coincide y si el estado también coincide
        bool matchesIsWave = batch.isWave.toString() == event.isWave;
        bool matchesStatus = batch.state == status;

        // Retornamos verdadero solo si ambas condiciones son verdaderas
        return matchesIsWave && matchesStatus;
      }).toList();
    }

    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  void _onFilterBatchesByOperationTypeEvent(
      FilterBatchesByOperationTypeEvent event, Emitter<PickingState> emit) {
    String status = '';
    if (event.operationType != 'Todos') {
      switch (event.indexMenu) {
        case 0:
          filteredBatchs = listOfBatchs;
          break;
        case 1:
          status = 'in_progress';
          break;
        case 2:
          status = 'done';
          break;

        default:
      }
      if (status != "") {
        filteredBatchs = listOfBatchs.where((batch) {
          // Obtener el pickingTypeId y dividirlo
          String pickingTypeId = batch.pickingTypeId ?? '';
          List<String> parts = pickingTypeId.split(':');
          String operationTypeFromBatch =
              parts.length > 1 ? parts[1].trim() : '';
          // Comparamos con el evento
          bool matchesOperationType =
              operationTypeFromBatch == event.operationType;
          // Comparamos el estado
          bool matchesStatus = batch.state == status;
          // Retornamos verdadero solo si ambas condiciones son verdaderas
          return matchesOperationType && matchesStatus;
        }).toList();
      } else {
        filteredBatchs = filteredBatchs.where((batch) {
          // Supongamos que batch.pickingTypeId es un string
          String pickingTypeId = batch.pickingTypeId ?? '';
          List<String> parts = pickingTypeId.split(':');
          // Obtener la parte después de los dos puntos y quitar espacios
          String operationTypeFromBatch =
              parts.length > 1 ? parts[1].trim() : '';

          // Comparamos con el evento
          return operationTypeFromBatch == event.operationType;
        }).toList();
      }
    } else {
      switch (event.indexMenu) {
        case 0:
          add(FilterBatchesBStatusEvent(''));
          break;
        case 1:
          add(FilterBatchesBStatusEvent('in_progress'));
          break;
        case 2:
          add(FilterBatchesBStatusEvent('done'));
          status = 'done';
          break;
        default:
      }
    }
    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  void _onFilterBatchesBStatusEvent(
      FilterBatchesBStatusEvent event, Emitter<PickingState> emit) async {
    if (event.status == '') {
      final batchsFromDB = await _databas.getAllBatchs();
      filteredBatchs = batchsFromDB;
      filteredBatchs = filteredBatchs
          .where((element) => element.isSeparate == null)
          .toList();
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    } else if (event.status == 'done') {
      filteredBatchs = batchsDone;
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    }
  }

  void _onLoadAllBatchsEvent(
      LoadAllBatchsEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchsPickingLoadingState());

      final response = await wmsPickingRepository.resBatchs();

      if (response != null && response is List) {
        print('response batchs: ${response.length}');
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite().insertBatch(BatchsModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduleddate: batch.scheduleddate ?? DateTime.now(),
                pickingTypeId: batch.pickingTypeId,
                muelle: batch.muelle,
                state: batch.state,
                userId: batch.userId,
                isWave: batch.isWave.toString(),
                countItems: batch.countItems,
              ));
            }
          } catch (dbError, stackTrace) {
            print('Error inserting batch: $dbError  $stackTrace');
          }
        }

        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<ProductsBatch> productsToInsert =
            listOfBatchs.expand((batch) => batch.listItems!).toList();
        sortProductsByLocationId(productsToInsert);

        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = listOfBatchs
            .expand((batch) => batch.listItems!)
            .expand((product) => product.productPacking!)
            .toList();

      print('productsToInsert: ${productsToInsert.length}');
      print('barcodesToInsert: ${barcodesToInsert.length}');
        // Enviar la lista agrupada a insertBatchProducts
        await DataBaseSqlite().insertBatchProducts(productsToInsert);

        // Enviar la lista agrupada a insertBarcodesPackageProduct
        await DataBaseSqlite().insertBarcodesPackageProduct(barcodesToInsert);

        //* Carga los batches desde la base de datos
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

  void _onLoadBatchsFromDBEvent(
      LoadBatchsFromDBEvent event, Emitter<PickingState> emit) async {
    try {
      batchsDone.clear();
      emit(BatchsPickingLoadingState());
      final batchsFromDB = await _databas.getAllBatchs();

      filteredBatchs = batchsFromDB;

      batchsDone =
          batchsFromDB.where((batch) => batch.isSeparate == 1).toList();
      //filtramos los batch que tenga is_seprate en 1
      filteredBatchs = filteredBatchs
          .where((element) => element.isSeparate == null)
          .toList();

      print('batchsDone: ${batchsDone.length}');

      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
    } catch (e) {
      print('Error loading batchs from DB: $e');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onSearchBacthEvent(
      SearchBatchEvent event, Emitter<PickingState> emit) async {
    final query = event.query.toLowerCase();
    final batchsFromDB = await _databas.getAllBatchs();
    if (event.indexMenu == 0) {
      if (query.isEmpty) {
        filteredBatchs = batchsFromDB;
        filteredBatchs = filteredBatchs
            .where((element) => element.isSeparate == null)
            .toList();
      } else {
        filteredBatchs = batchsFromDB.where((batch) {
          return batch.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      // Emitir la lista filtrada
    } else {
      if (query.isEmpty) {
        filteredBatchs = batchsDone;
      } else {
        filteredBatchs = batchsDone.where((batch) {
          return batch.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
    }
    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  void sortProductsByLocationId(List<ProductsBatch> products) {
    products.sort((a, b) {
      // Comparamos los locationId
      return a.locationId?[1].compareTo(b.locationId?[1]);
    });
  }
}
