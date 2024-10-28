// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, unnecessary_import, unrelated_type_equality_checks, use_build_context_synchronously

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_api_module.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';

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

    //* filtrar por tipo de operacion
    on<FilterBatchesByOperationTypeEvent>(_onFilterBatchesByOperationTypeEvent);

    //* filtrar por tipo de batch o wave
    on<FilterBatchesByTypeEvent>(_onFilterBatchesByTypeEvent);
  }

  void _onFilterBatchesByTypeEvent(
      FilterBatchesByTypeEvent event, Emitter<PickingState> emit) {
    String status = '';
    if (event.indexMenu == 0) {
      filteredBatchs = listOfBatchs.where((batch) {
        return batch.isWave.toString() == event.isWave;
      }).toList();
    } else {
      switch (event.indexMenu) {
        case 1:
          status = 'in_progress';
          break;
        case 2:
          status = 'done';
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
          String pickingTypeId = batch.pickingTypeId[1] ?? '';
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
          String pickingTypeId = batch.pickingTypeId[1] ?? '';
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

      final response = await PickingApiModule.resBatchs(event.context);
      if (response != null && response is List) {
        print('response batchs: ${response.length}');
        List<int> idBatchs = [];
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite().insertBatch(BatchsModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduledDate: batch.scheduledDate ?? 'no scheduled',
                pickingTypeId: (batch.pickingTypeId is List &&
                        batch.pickingTypeId.isNotEmpty)
                    ? batch.pickingTypeId[1]
                    : '',

                locationId: (batch.locationId is List &&
                        batch.locationId.isNotEmpty)
                    ? batch.locationId[1]
                    : '',
                state: batch.state,
                userId: batch.userId is bool
                    ? ""
                    : (batch.userId.isNotEmpty ? batch.userId[1] : ''),
                isWave: batch.isWave.toString(),
              ));
              idBatchs.add(batch.id!);
            }
          } catch (dbError, stackTrace) {
            print('Error inserting batch: $dbError  $stackTrace');
          }
        }

        if (idBatchs.isNotEmpty) {
          // Obtén todos los productos de los batches en progreso
          final responseProductsBatchs =
              await PickingApiModule.resAllProductsBatchApi(
                  idBatchs, event.context);

          print('responseProductsBatchs: ${responseProductsBatchs.length}');

          if (responseProductsBatchs.isNotEmpty) {
            // Crear un mapa para almacenar los productos únicos y sumar cantidades
            Map<String, ProductsBatch> uniqueProductsMap = {};

            for (var productsBatch in responseProductsBatchs) {
              // Crear una clave única usando idProduct y batchId
              String key =
                  '${productsBatch.idProduct}-${productsBatch.batchId}';

              if (uniqueProductsMap.containsKey(key)) {
                // Si ya existe en el mapa, sumar la cantidad al producto existente
                uniqueProductsMap[key]!.quantity +=
                    productsBatch.quantity.toInt();
              } else {
                // Si no existe, agregarlo al mapa
                uniqueProductsMap[key] = ProductsBatch(
                  idProduct: productsBatch.idProduct,
                  batchId: productsBatch.batchId,
                  productId: productsBatch.productId,
                  pickingId: productsBatch.pickingId,
                  lotId: productsBatch.lotId,
                  locationId: productsBatch.locationId,
                  locationDestId: productsBatch.locationDestId,
                  quantity: productsBatch.quantity.toInt(),
                );
              }
            }

            // Convertir el mapa en una lista de productos únicos con cantidades sumadas
            List<ProductsBatch> productsToInsert =
                uniqueProductsMap.values.toList();

            sortProductsByLocationId(productsToInsert);

            // Enviar la lista agrupada a insertBatchProducts
            await DataBaseSqlite().insertBatchProducts(productsToInsert);
          }
        }

        final responseProductsAll =
            await PickingApiModule.resProductsApi(event.context);
        print('responseProductsAll: ${responseProductsAll.length}');

        await DataBaseSqlite().insertProducts(responseProductsAll);

        // Carga los batches desde la base de datos
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

  void sortProductsByLocationId(List<ProductsBatch> products) {
    products.sort((a, b) {
      // Comparamos los locationId
      return a.locationId.compareTo(b.locationId);
    });
  }
}
