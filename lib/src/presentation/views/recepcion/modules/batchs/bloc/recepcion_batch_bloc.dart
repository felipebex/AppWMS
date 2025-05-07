import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_batch_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'recepcion_batch_event.dart';
part 'recepcion_batch_state.dart';

class RecepcionBatchBloc
    extends Bloc<RecepcionBatchEvent, RecepcionBatchState> {
  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();
  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();
  //*repository
  final RecepcionRepository _recepcionRepository = RecepcionRepository();

  List<ReceptionBatch> listReceptionBatch = [];
  List<ReceptionBatch> listReceptionBatchFilter = [];

  //controller
  final TextEditingController searchControllerRecepcionBatch =
      TextEditingController();

  bool isKeyboardVisible = false;

  RecepcionBatchBloc() : super(RecepcionBatchInitial()) {
    on<RecepcionBatchEvent>((event, emit) {});

    //* obtener todas las repeciones por batch
    on<FetchRecepcionBatchEvent>(_onFetchRecepcionBatchEvent);
    //*cargar toddas las recepciones por batch desde la bd
    on<FetchRecepcionBatchEventFromBD>(_onFetchRecepcionBatchEventFromBD);

    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //* buscar una orden de compra
    on<SearchReceptionEvent>(_onSearchOrderEvent);

    //*asignar un usuario a una orden de compra
    on<AssignUserToReception>(_onAssignUserToOrder);

    //*metodo para empezar o terminar timepo
    on<StartOrStopTimeOrder>(_onStartOrStopTimeOrder);
  }

  ///*metodo para asignar tiempo de inicio o fin
  ///
  void _onStartOrStopTimeOrder(
      StartOrStopTimeOrder event, Emitter<RecepcionBatchState> emit) async {
    try {
      final time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      if (event.value == "start_time_reception") {
        await db.entradaBatchRepository.setFieldTableEntradaBatch(
          event.idRecepcion,
          "start_time_reception",
          time,
        );
      } else if (event.value == "end_time_reception") {
        await db.entradaBatchRepository.setFieldTableEntradaBatch(
          event.idRecepcion,
          "end_time_reception",
          time,
        );
      }
      await db.entradaBatchRepository.setFieldTableEntradaBatch(
        event.idRecepcion,
        "is_selected",
        1,
      );
      await db.entradaBatchRepository.setFieldTableEntradaBatch(
        event.idRecepcion,
        "is_started",
        1,
      );

      //hacemos la peticion de mandar el tiempo
      final response = await _recepcionRepository.sendTime(
        event.idRecepcion,
        event.value,
        time,
        false,
      );

      if (response) {
        emit(StartOrStopTimeOrderSuccess(event.value));
      } else {
        emit(StartOrStopTimeOrderFailure('Error al enviar el tiempo'));
      }
    } catch (e, s) {
      print('Error en el _onStartOrStopTimeOrder: $e, $s');
    }
  }

  //*metodo para asignar un usuario a una orden de compra
  void _onAssignUserToOrder(
      AssignUserToReception event, Emitter<RecepcionBatchState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      String nameUser = await PrefUtils.getUserName();
      emit(AssignUserToOrderLoading());
      final response = await _recepcionRepository.assignUserToReceptionBatch(
        true,
        userId,
        event.order.id ?? 0,
      );

      if (response) {
        //actualizamos la tabla entrada:
        await db.entradaBatchRepository.setFieldTableEntradaBatch(
          event.order.id ?? 0,
          "responsable_id",
          userId,
        );

        await db.entradaBatchRepository.setFieldTableEntradaBatch(
          event.order.id ?? 0,
          "responsable",
          nameUser,
        );
        await db.entradaBatchRepository.setFieldTableEntradaBatch(
          event.order.id ?? 0,
          "is_selected",
          1,
        );

        // add(StartOrStopTimeOrder(
        //   event.order.id ?? 0,
        //   "start_time_reception",
        // ));

        emit(AssignUserToOrderSuccess(event.order));
      } else {
        emit(AssignUserToOrderFailure(
            "La recepción ya tiene un responsable asignado"));
      }
    } catch (e, s) {
      emit(AssignUserToOrderFailure('Error al asignar el usuario'));
      print('Error en el _onAssignUserToOrder: $e, $s');
    }
  }

  //*metodo para buscar una entrada

  void _onSearchOrderEvent(
      SearchReceptionEvent event, Emitter<RecepcionBatchState> emit) async {
    try {
      listReceptionBatchFilter = [];
      listReceptionBatchFilter = listReceptionBatch;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        listReceptionBatchFilter = listReceptionBatch;
      } else {
        listReceptionBatchFilter = listReceptionBatchFilter.where((element) {
          // Filtrar por nombre o proveedor (si el proveedor no es nulo o vacío)
          return element.name!.toLowerCase().contains(query) ||
              (element.proveedor != null &&
                  element.proveedor!.toLowerCase().contains(query)) ||
              (element.purchaseOrderName != null &&
                  element.purchaseOrderName!.toLowerCase().contains(query));
        }).toList();
      }

      emit(SearchOrdenCompraSuccess(listReceptionBatchFilter));
    } catch (e, s) {
      emit(SearchOrdenCompraFailure('Error al buscar la orden de compra'));
      print('Error en el _onSearchPedidoEvent: $e, $s');
    }
  }

  //*metodo para ocultar y mostrar el teclado
  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<RecepcionBatchState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //*metodo para obtener todas las recepciones por batch
  void _onFetchRecepcionBatchEvent(
      FetchRecepcionBatchEvent event, Emitter<RecepcionBatchState> emit) async {
    emit(FetchRecepcionBatchLoading());
    try {
      //limpiamos la tabla de recepcion por batch
      await db.deleReceptionBatch();
      listReceptionBatch.clear();

      final response = await _recepcionRepository
          .fetchAllBatchReceptions(event.isLoadinDialog);

      if (response.result?.code == 200) {
        if (response.result?.result?.isNotEmpty == true) {
          final listReceptionBatch = response.result?.result;
          print('cantidad de recepciones: ${listReceptionBatch?.length}');
          //insertamos en la base de datos
          await db.entradaBatchRepository.insertEntradaBatch(
            listReceptionBatch!,
          );

          //obtenemos los productos de todas las recepciones para guardarlos en la bd:
          final productsToInsert =
              _getAllProducts(listReceptionBatch!).toList(growable: false);

          final productsSedToInsert =
              _getAllSentProducts(listReceptionBatch).toList(growable: false);
          final allBarcodes =
              _getAllBarcodes(listReceptionBatch).toList(growable: false);

          

          add(FetchRecepcionBatchEventFromBD());
          emit(FetchRecepcionBatchSuccess(
              listReceptionBatch: listReceptionBatch));
        }
        emit(FetchRecepcionBatchSuccess(listReceptionBatch: []));
      } else {
        emit(FetchRecepcionBatchFailure(response.result?.msg ?? ""));
      }
    } catch (e) {
      emit(FetchRecepcionBatchFailure(e.toString()));
    }
  }

  Iterable<LineasRecepcion> _getAllProducts(
      List<ReceptionBatch> batches) sync* {
    for (final batch in batches) {
      if (batch.lineasRecepcion != null) yield* batch.lineasRecepcion!;
    }
  }

  Iterable<LineasRecepcion> _getAllSentProducts(
      List<ReceptionBatch> batches) sync* {
    for (final batch in batches) {
      if (batch.lineasRecepcionEnviadas != null) {
        yield* batch.lineasRecepcionEnviadas!;
      }
    }
  }
// Generador para todos los códigos de barras

  Iterable<Barcodes> _getAllBarcodes(List<ReceptionBatch> batches) sync* {
    for (final batch in batches) {
      if (batch.lineasRecepcion != null) {
        for (final product in batch.lineasRecepcion!) {
          if (product.otherBarcodes != null) yield* product.otherBarcodes!;
          if (product.productPacking != null) yield* product.productPacking!;
        }
      }
    }
  }

//*metodo para cargar todas las recepciones por batch desde la bd
  void _onFetchRecepcionBatchEventFromBD(FetchRecepcionBatchEventFromBD event,
      Emitter<RecepcionBatchState> emit) async {
    emit(FetchRecepcionBatchLoadingFromBD());
    try {
      listReceptionBatch.clear();
      listReceptionBatchFilter.clear();
      final response = await db.entradaBatchRepository.getAllEntradaBatch();

      if (response.isNotEmpty) {
        listReceptionBatch.addAll(response);
        listReceptionBatchFilter.addAll(response);
        emit(FetchRecepcionBatchSuccessFromBD(listReceptionBatch: response));
      } else {
        emit(FetchRecepcionBatchFailureFromBD("No hay recepciones por batch"));
      }
    } catch (e) {
      emit(FetchRecepcionBatchFailureFromBD(e.toString()));
    }
  }
}
