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
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'wms_picking_event.dart';
part 'wms_picking_state.dart';

class WMSPickingBloc extends Bloc<PickingEvent, PickingState> {
  //*batchs
  List<BatchsModel> listOfBatchs = [];
  List<BatchsModel> filteredBatchs = []; // Lista para los productos filtrados
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
      final novedadeslist = await wmsPickingRepository.getnovedades(
        false,
      );
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

    filteredBatchs.clear();
    filteredBatchs = batchsFromDB;

    emit(LoadBatchsSuccesBDState(listOfBatchs: filteredBatchs));
  }

  void _onLoadAllBatchsEvent(
      LoadAllBatchsEvent event, Emitter<PickingState> emit) async {
    try {
      emit(BatchsPickingLoadingState());

      final response = await wmsPickingRepository.resBatchs(
        event.isLoadinDialog,
      );

      if (response != null && response is List) {
        int userId = await PrefUtils.getUserId();
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        if (listOfBatchs.isNotEmpty) {
          await DataBaseSqlite()
              .batchPickingRepository
              .insertAllBatches(listOfBatchs, userId);

          // Convertir el mapa en una lista de productos únicos con cantidades sumadas
          final productsIterable =
              _extractAllProducts(listOfBatchs).toList(growable: false);

          final allBarcodes =
              _extractAllBarcodes(response).toList(growable: false);

          final List<Muelles> responseMuelles =
              await wmsPickingRepository.getmuelles(
            false,
          );

          print('response muelles: ${responseMuelles.length}');
          print('productsToInsert: ${productsIterable.length}');
          print('allBarcodes: ${allBarcodes.length}');

          await DataBaseSqlite()
              .submuellesRepository
              .insertSubmuelles(responseMuelles);

          // Enviar la lista agrupada a insertBatchProducts
          await DataBaseSqlite().insertBatchProducts(productsIterable);

          if (allBarcodes.isNotEmpty) {
            // Enviar la lista agrupada a insertBarcodesPackageProduct
            await DataBaseSqlite()
                .barcodesPackagesRepository
                .insertOrUpdateBarcodes(allBarcodes);
          }

          // //* Carga los batches desde la base de datos
          add(FilterBatchesBStatusEvent(
            '',
          ));
        }

        emit(LoadBatchsSuccesState(listOfBatchs: listOfBatchs));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error LoadAllBatchsEvent: $e, $s');
      emit(BatchsPickingErrorState(e.toString()));
    }
  }

  Iterable<Barcodes> _extractAllBarcodes(List<BatchsModel> batches) sync* {
    for (final batch in batches) {
      if (batch.listItems == null) continue;

      for (final product in batch.listItems!) {
        if (product.productPacking != null) {
          yield* product.productPacking!;
        }
        if (product.otherBarcode != null) {
          yield* product.otherBarcode!;
        }
      }
    }
  }

  Iterable<ProductsBatch> _extractAllProducts(List<BatchsModel> batches) sync* {
    for (final batch in batches) {
      if (batch.listItems != null) {
        yield* batch.listItems!;
      }
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
