// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, unnecessary_import, unrelated_type_equality_checks, use_build_context_synchronously

import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_piicking_rerpository.dart';
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

  List<Novedad> listOfNovedades = [];
  bool isKeyboardVisible = false;

  WmsPickingRepository wmsPickingRepository = WmsPickingRepository();

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*instancia de la base de datos
  final DataBaseSqlite _databas = DataBaseSqlite();

  WMSPickingBloc() : super(ProductspickingInitial()) {
    //*filtrar los batchs por fecha
    on<FilterBatchsByDateEvent>(_onFilterBatchsByDateEvent);

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
          await wmsPickingRepository.getnovedades(false, event.context);
      listOfNovedades.clear();
      listOfNovedades.addAll(novedadeslist);

      //agrgegar las novedades a la base de datos
      for (var novedad in listOfNovedades) {
        try {
          if (novedad.id != null && novedad.name != null) {
            await DataBaseSqlite().insertNovedad(Novedad(
              id: novedad.id,
              name: novedad.name,
              code: novedad.code,
            ));
          }
        } catch (dbError, stackTrace) {
          print('Error inserting novedades: $dbError  $stackTrace');
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

  //*metodo para filtrar los batchs por fecha
  void _onFilterBatchsByDateEvent(
      FilterBatchsByDateEvent event, Emitter<PickingState> emit) async {
    final date = event.date;
    final int indexMenu = event.indexMenu;
    final int userId = await PrefUtils.getUserId();

    final batchsFromDB = await _databas.getAllBatchs(userId);
    print('batchsFromDB: ${batchsFromDB.length}');
    if (indexMenu == 0) {
      filteredBatchs.clear();
      print("batch en proceso");
      //bathc en proceso

      filteredBatchs = batchsFromDB
          .where((batch) =>
              batch.scheduleddate != null &&
              //la fechha es un string
              DateTime.parse(batch.scheduleddate).day == date.day &&
              DateTime.parse(batch.scheduleddate).month == date.month &&
              DateTime.parse(batch.scheduleddate).year == date.year &&
              batch.isSeparate == null)
          .toList();
    } else {
      filteredBatchs.clear();
      print("batch hechos");

      //batche ne hecho guardado en bd local
      filteredBatchs = batchsDone
          .where((batch) =>
              batch.scheduleddate != null &&
              batch.isSeparate == 1 &&
              DateTime.parse(batch.scheduleddate).day == date.day &&
              DateTime.parse(batch.scheduleddate).month == date.month &&
              DateTime.parse(batch.scheduleddate).year == date.year)
          .toList();
    }

    print('filteredBatchs: ${filteredBatchs.length}');

    emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
  }

  //*metodo para filtrar los batchs por tipo de batch
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
    final int userId = await PrefUtils.getUserId();

    if (event.status == '') {
      final batchsFromDB = await _databas.getAllBatchs(userId);

      filteredBatchs = batchsFromDB;
      filteredBatchs = filteredBatchs.where((element) {
        return DateTime.parse(element.scheduleddate ?? "")
                    .toString()
                    .substring(0, 10) ==
                DateTime.now().toString().substring(0, 10) &&
            element.isSeparate == null;
      }).toList();
      emit(LoadBatchsSuccesState(listOfBatchs: filteredBatchs));
      return;
    } else if (event.status == 'done') {
      filteredBatchs = batchsDone.where((batch) {
        return DateTime.parse(batch.timeSeparateEnd ?? "")
                .toString()
                .substring(0, 10) ==
            DateTime.now().toString().substring(0, 10);
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
        event.context,
      );

      if (response != null && response is List) {
        // validamos que si hace la petición cada 3 minutos
        if (!event.isLoadinDialog) {
          final int userid = await PrefUtils.getUserId();
          final intBacths = await DataBaseSqlite().getAllBatchs(userid);

          final todayBatches = intBacths.where((batch) {
            // Convierte `scheduleddate` a DateTime
            final scheduledDate = DateTime.parse(batch.scheduleddate);

            // Obtén la fecha actual
            final today = DateTime.now();

            // Compara día, mes y año
            return scheduledDate.year == today.year &&
                scheduledDate.month == today.month &&
                scheduledDate.day == today.day;
          }).toList();

          final todayBatchesOdoo = response.where((batch) {
            // Convierte `scheduleddate` a DateTime
            final scheduledDate = DateTime.parse(batch.scheduleddate);
            final today = DateTime.now();
            return scheduledDate.year == today.year &&
                scheduledDate.month == today.month &&
                scheduledDate.day == today.day;
          }).toList();

          if (todayBatchesOdoo.length > todayBatches.length) {
            //mostramos una notificación
            LocalNotificationsService().showNotification('Nuevos batchs',
                'Se han agregado nuevos batchs para picking', '');
          }
        }

        print('response batchs: ${response.length}');
        PrefUtils.setPickingBatchs(response.length);
        int userId = await PrefUtils.getUserId();
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              print(
                  'batch.id: ${batch.id} scheduleddate: ${batch.scheduleddate}');
              await DataBaseSqlite().insertBatch(BatchsModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduleddate: batch.scheduleddate.toString(),
                pickingTypeId: batch.pickingTypeId,
                muelle: batch.muelle,
                state: batch.state,
                userId: userId,
                userName: batch.userName,
                isWave: batch.isWave.toString(),
                countItems: batch.countItems,
                orderBy: batch.orderBy,
                orderPicking: batch.orderPicking,
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
          event.isLoadinDialog,
          event.context,
        );

        print('response muelles: ${responseMuelles.length}');

        print('productsToInsert: ${productsToInsert.length}');
        print('barcodesToInsert: ${barcodesToInsert.length}');
        print('otherBarcodesToInsert: ${otherBarcodesToInsert.length}');

        await DataBaseSqlite().insertSubmuelles(responseMuelles);

        // Enviar la lista agrupada a insertBatchProducts
        await DataBaseSqlite().insertBatchProducts(productsToInsert);

        // Enviar la lista agrupada a insertBarcodesPackageProduct
        await DataBaseSqlite().insertBarcodesPackageProduct(barcodesToInsert);
        await DataBaseSqlite()
            .insertBarcodesPackageProduct(otherBarcodesToInsert);

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
      final int userId = await PrefUtils.getUserId();

      batchsDone.clear();
      emit(BatchsPickingLoadingState());
      final batchsFromDB = await _databas.getAllBatchs(userId);

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
    print('event._onSearchBacthEvent: ${event.query}');
    final query = event.query.toLowerCase();
    final int userid = await PrefUtils.getUserId();
    final batchsFromDB = await _databas.getAllBatchs(userid);
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
}
