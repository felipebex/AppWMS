// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';

part 'wms_packing_event.dart';
part 'wms_packing_state.dart';

class WmsPackingBloc extends Bloc<WmsPackingEvent, WmsPackingState> {
  
  //*lista de batchs para packing
  List<BatchPackingModel> listOfBatchs = [];
  List<BatchPackingModel> listOfBatchsDB = [];
  
  //*listad de pedido de un batch
  List<PedidoPacking> listOfPedidos = [];

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  String oldLocation = '';

  int completedProducts = 0;

  //*numero de paquetes
  int numPackages = 0;

  //Lista de paquetes
  List<String> packages = [];

  int index = 0;

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  WmsPackingBloc() : super(WmsPackingInitial()) {
    //*obtener todos los batchs para packing de odoo
    on<LoadAllPackingEvent>(_onLoadAllPackingEvent);
    //*obtener todos los batchs para packing de la base de datos
    on<LoadBatchPackingFromDBEvent>(_onLoadBatchsFromDBEvent);
    //*obtener todos los pedidos de un batch
    on<LoadAllPedidosFromBatchEvent>(_onLoadAllPedidosFromBatchEvent);
    //*obtener todos los productos de un pedido
    on<LoadAllProductsFromPedidoEvent>(_onLoadAllProductsFromPedidoEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*agregar un producto a nuevo empaque
    on<AddProductPackingEvent>(_onAddProductPackingEvent);
  }




void _onLoadAllProductsFromPedidoEvent(
      LoadAllProductsFromPedidoEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(WmsPackingLoading());




    
    } catch (e, s) {
      print('Error en el  _onLoadAllProductsFromPedidoEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }


  void _onLoadAllPedidosFromBatchEvent(
      LoadAllPedidosFromBatchEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(WmsPackingLoading());
      final response = await DataBaseSqlite().getPedidosPacking(event.batchId);
      if (response != null && response is List) {
        print('response pedidos: ${response.length}');
        listOfPedidos.clear();
        listOfPedidos.addAll(response);
        print('pedidosToInsert: ${response.length}');
        emit(WmsPackingLoaded(listOfBatchsDB));
      } else {
        print('Error resPedidos: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPedidosFromBatchEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }



  void getPosicions() {}

  void _onAddProductPackingEvent(
      AddProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {} catch (e, s) {
      print('Error en el  _onAddProductPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadAllPackingEvent(
      LoadAllPackingEvent event, Emitter<WmsPackingState> emit) async {
    emit(WmsPackingLoading());
    try {
      final response = await wmsPackingRepository.resBatchsPacking();

      if (response != null && response is List) {
        print('response batchs: ${response.length}');
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite().insertBatchPacking(BatchPackingModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduleddate: batch.scheduleddate ?? DateTime.now(),
                pickingTypeId: batch.pickingTypeId,
                state: batch.state,
                userId: batch.userId.toString(),
              ));
            }
          } catch (dbError, stackTrace) {
            print('Error insertBatchPacking: $dbError  $stackTrace');
          }
        }

        // Convertir el mapa en una lista de pedido unicos del batch para packing
        List<PedidoPacking> pedidosToInsert =
            listOfBatchs.expand((batch) => batch.listaPedidos!).toList();

        print('pedidosToInsert: ${pedidosToInsert.length}');

        // Enviar la lista agrupada de productos de un batch para packing
        await DataBaseSqlite().insertPedidosBatchPacking(pedidosToInsert);


        //convertir el mapa en una lista de productos unicos del pedido para packing
        List<ListaProducto> productsToInsert = pedidosToInsert
            .expand((pedido) => pedido.listaProductos!)
            .toList();

        print('productsToInsert: ${productsToInsert.length}');
        // Enviar la lista agrupada de productos de un pedido para packing
        await DataBaseSqlite().insertProductosPedidos(productsToInsert);


        // //* Carga los batches desde la base de datos
        add(LoadBatchPackingFromDBEvent());
        emit(WmsPackingLoaded(listOfBatchs));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadBatchsFromDBEvent(
      LoadBatchPackingFromDBEvent event, Emitter<WmsPackingState> emit) async{
    try {
      emit(BatchsPackingLoadingState());
      final  batchsFromDB = await DataBaseSqlite().getAllBatchsPacking();
      listOfBatchsDB.clear();
      listOfBatchsDB.addAll(batchsFromDB);
      print('batchsFromDB: ${batchsFromDB.length}');
      emit(WmsPackingLoaded(listOfBatchsDB));
    } catch (e, s) {
      print('Error en el  _onLoadBatchsFromDBEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<WmsPackingState> emit) {
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<WmsPackingState> emit) {
    locationIsOk = event.locationIsOk;
    emit(ChangeIsOkState(
      locationIsOk,
    ));
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<WmsPackingState> emit) {
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<WmsPackingState> emit) {
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }
}
