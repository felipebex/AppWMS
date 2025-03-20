// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, unnecessary_import, unrelated_type_equality_checks, use_build_context_synchronously

import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_repository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/models/batch_history_id_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/models/hisotry_done_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';
import 'package:wms_app/src/services/notification_service.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'wms_picking_event.dart';
part 'wms_picking_state.dart';

class WMSPickingBloc extends Bloc<PickingEvent, PickingState> {
  //*batchs
  List<BatchsModel> listOfBatchs = [];
  List<BatchsModel> filteredBatchs = []; // Lista para los productos filtrados
  List<BatchsModel> batchsDone = []; // Lista para los productos filtrados
  List<HistoryBatch> historyBatchs = []; // Lista para los productos filtrados
  List<HistoryBatch> filtersHistoryBatchs =
      []; // Lista para los productos filtrados

  List<Novedad> listOfNovedades = [];
  bool isKeyboardVisible = false;

  HistoryBatchId historyBatchId = HistoryBatchId();

  WmsPickingRepository wmsPickingRepository = WmsPickingRepository();

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();
  TextEditingController searchHistoryController = TextEditingController();

  //*instancia de la base de datos
  final DataBaseSqlite _databas = DataBaseSqlite();

  WMSPickingBloc() : super(ProductspickingInitial()) {
    //*filtrar los batchs por fecha

    //*obtener todos los batchs desde odoo
    on<LoadAllBatchsEvent>(_onLoadAllBatchsEvent);
    //*obtener todos los batchs desde el historial de odoo
    on<LoadHistoryBatchsEvent>(_onLoadHistoryBatchsEvent);
    //*obtener un batch por id del hisorial
    on<LoadHistoryBatchIdEvent>(_onLoadHistoryBatchIdEvent);
    //*buscar un batch
    on<SearchBatchEvent>(_onSearchBacthEvent);
    //*Buscar un batch en el historial
    on<SearchBatchHistoryEvent>(_onSearchBacthHistoryEvent);
    // *filtrar por estado los batchs desde SQLite
    on<FilterBatchesBStatusEvent>(_onFilterBatchesBStatusEvent);
    //evento para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //evento para obtener todas las novedades desde odoo
    on<LoadAllNovedades>(_onLoadAllNovedadesEvent);
  }

  //*metodo para cargar todas las novedades

  void _onLoadAllNovedadesEvent(
      LoadAllNovedades event, Emitter<PickingState> emit) async {
    try {
      final novedadeslist =
          await wmsPickingRepository.getnovedades(false, );
      listOfNovedades.clear();
      listOfNovedades.addAll(novedadeslist);

      // Si hay novedades para insertar, ejecutar la inserción en batch
      if (listOfNovedades.isNotEmpty) {
        try {
          await DataBaseSqlite()
              .novedadesRepository
              .insertBatchNovedades(listOfNovedades);
          print('Novedades insertadas con éxito.');
        } catch (e) {
          print('Error inserting batch of novedades: $e');
        }
      }

      emit(LoadSuccessNovedadesState(listOfNovedades: listOfNovedades));
    } catch (e, s) {
      print('Error LoadAllNovedadesEvent: $e, $s');
    }
  }

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<PickingState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onFilterBatchesBStatusEvent(
      FilterBatchesBStatusEvent event, Emitter<PickingState> emit) async {
    final int userId = await PrefUtils.getUserId();
    final batchsFromDB =
        await _databas.batchPickingRepository.getAllBatchs(userId);

    batchsDone = batchsFromDB.where((batch) => batch.isSeparate == 1).toList();

    if (event.status == '') {
      filteredBatchs = batchsFromDB.where((batch) {
        return batch.isSeparate == null;
      }).toList();
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    }
    //else
    if (event.status == 'done') {
      filteredBatchs = batchsFromDB.where((batch) {
        return batch.isSeparate != null;
      }).toList();
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    }
  }

  void _onLoadAllBatchsEvent(
      LoadAllBatchsEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchsPickingLoadingState());

      final response = await wmsPickingRepository.resBatchs(
        event.isLoadinDialog,
      );

      if (response != null && response is List) {
        if (response.isNotEmpty) {
          LocalNotificationsService().showNotification('Nuevos batchs',
              'Se han agregado nuevos batchs para picking', '');
        }

        int userId = await PrefUtils.getUserId();
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite()
                  .batchPickingRepository
                  .insertBatch(BatchsModel(
                    id: batch.id!,
                    name: batch.name ?? '',
                    scheduleddate: batch.scheduleddate.toString(),
                    pickingTypeId: batch.pickingTypeId,
                    muelle: batch.muelle,
                    barcodeMuelle: batch.barcodeMuelle,
                    idMuelle: batch.idMuelle,
                    state: batch.state,
                    userId: userId,
                    userName: batch.userName,
                    isWave: batch.isWave.toString(),
                    countItems: batch.countItems,
                    totalQuantityItems: batch.totalQuantityItems.toInt(),
                    orderBy: batch.orderBy,
                    orderPicking: batch.orderPicking,
                    indexList: 0,
                    startTimePick: batch.startTimePick,
                    endTimePick: batch.endTimePick,
                    zonaEntrega: batch.zonaEntrega,
                  ));
            }
          } catch (dbError, stackTrace) {
            print('Error inserting batch: $dbError  $stackTrace');
          }
        }

        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<ProductsBatch> productsToInsert =
            listOfBatchs.expand((batch) => batch.listItems!).toList();

        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = listOfBatchs
            .expand((batch) => batch.listItems!)
            .expand((product) => product.productPacking!)
            .toList();

        //convertir el mapap en una lsita de los otros barcodes de cada producto
        List<Barcodes> otherBarcodesToInsert = listOfBatchs
            .expand((batch) => batch.listItems!)
            .expand((barcode) => barcode.otherBarcode!)
            .toList();

        final List<Muelles> responseMuelles =
            await wmsPickingRepository.getmuelles(
          false,
        );

        print('response muelles: ${responseMuelles.length}');
        print('productsToInsert: ${productsToInsert.length}');
        print('barcodesToInsert: ${barcodesToInsert.length}');
        print('otherBarcodesToInsert: ${otherBarcodesToInsert.length}');

        await DataBaseSqlite()
            .submuellesRepository
            .insertSubmuelles(responseMuelles);

        // Enviar la lista agrupada a insertBatchProducts
        await DataBaseSqlite().insertBatchProducts(productsToInsert);

        if (barcodesToInsert.isNotEmpty) {
          await DataBaseSqlite()
              .barcodesPackagesRepository
              .insertOrUpdateBarcodes(barcodesToInsert);
        }

        if (otherBarcodesToInsert.isNotEmpty) {
          // Enviar la lista agrupada a insertBarcodesPackageProduct
          await DataBaseSqlite()
              .barcodesPackagesRepository
              .insertOrUpdateBarcodes(otherBarcodesToInsert);

          
        }

        //* Carga los batches desde la base de datos
        add(FilterBatchesBStatusEvent(
          '',
        ));
        emit(LoadBatchsSuccesState(listOfBatchs: listOfBatchs));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error LoadAllBatchsEvent: $e, $s');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onLoadHistoryBatchsEvent(
      LoadHistoryBatchsEvent event, Emitter<PickingState> emit) async {
    try {
      print('date: ${event.date}');
      emit(BatchsPickingLoadingState());

      final response = await wmsPickingRepository.resBatchsHistory(
        event.isLoadinDialog,
        event.date,
      );

      if (response != null && response is List) {
        historyBatchs.clear();
        filtersHistoryBatchs.clear();
        historyBatchs.addAll(response);
        filtersHistoryBatchs.addAll(response);

        emit(LoadHistoryBatchState(listOfBatchs: filtersHistoryBatchs));
      } else {
        print('Error resHistoryBatchs: response is null');
      }
    } catch (e, s) {
      print('Error LoadHistoryBatchsEvent: $e, $s');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onLoadHistoryBatchIdEvent(
      LoadHistoryBatchIdEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchHistoryLoadingState());

      final response = await wmsPickingRepository.getBatchById(
        event.isLoadinDialog,
        event.batchId,
      );

      if (response != null && response is HistoryBatchId) {
        historyBatchId = HistoryBatchId();
        historyBatchId = response;
        emit(BatchHistoryLoadedState(historyBatchId));
      } else {
        print('Error resHistoryBatchs: response is null');
      }
    } catch (e, s) {
      print('Error LoadHistoryBatchsEvent: $e, $s');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  void _onSearchBacthEvent(
      SearchBatchEvent event, Emitter<PickingState> emit) async {
    print('event._onSearchBacthEvent: ${event.query}');
    final query = event.query.toLowerCase();
    final int userid = await PrefUtils.getUserId();
    final batchsFromDB =
        await _databas.batchPickingRepository.getAllBatchs(userid);
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

  void _onSearchBacthHistoryEvent(
      SearchBatchHistoryEvent event, Emitter<PickingState> emit) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      filtersHistoryBatchs = historyBatchs;
    } else {
      filtersHistoryBatchs = historyBatchs.where((batch) {
        return batch.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    }

    emit(LoadHistoryBatchState(listOfBatchs: filtersHistoryBatchs));
  }
}
