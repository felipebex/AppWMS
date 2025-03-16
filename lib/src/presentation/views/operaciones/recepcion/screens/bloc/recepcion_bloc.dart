// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';

part 'recepcion_event.dart';
part 'recepcion_state.dart';

class RecepcionBloc extends Bloc<RecepcionEvent, RecepcionState> {
  //*listado de entradas
  List<ResultEntrada> listOrdenesCompra = [];
  List<ResultEntrada> listFiltersOrdenesCompra = [];

  //*listado de productos de una entrada
  List<LineasRecepcion> listProductsEntrada = [];

  //*repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();
  //*controller de busqueda
  TextEditingController searchControllerOrderC = TextEditingController();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  int quantitySelected = 0;

//*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  RecepcionBloc() : super(RecepcionInitial()) {
    on<RecepcionEvent>((event, emit) {});
    //*obtener todas las ordenes de compra
    on<FetchOrdenesCompra>(_onFetchOrdenesCompra);
    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //* buscar una orden de compra
    on<SearchOrdenCompraEvent>(_onSearchOrderEvent);
    //*obtener las ordenes de compra de la bd
    on<FetchOrdenesCompraOfBd>(_onFetchOrdenesCompraOfBd);

    //*asignar un usuario a una orden de compra
    on<AssignUserToOrder>(_onAssignUserToOrder);
    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserOrder>(_onLoadConfigurationsUserEvent);
    //*obtener todos los productos de una entrada
    on<GetPorductsToEntrada>(_onGetProductsToEntrada);
  }

  //metodo para obtener los productos de una entrada por id
  void _onGetProductsToEntrada(
      GetPorductsToEntrada event, Emitter<RecepcionState> emit) async {
    try {
      emit(GetProductsToEntradaLoading());
      final response = await db.productEntradaRepository
          .getProductsByRecepcionId(event.idEntrada);

      if (response != null && response is List) {
        listProductsEntrada = [];
        listProductsEntrada = response;
        emit(GetProductsToEntradaSuccess(response));
      } else {
        emit(GetProductsToEntradaFailure(
            'Error al obtener los productos de la entrada'));
      }
    } catch (e, s) {
      emit(GetProductsToEntradaFailure(
          'Error al obtener los productos de la entrada'));
      print('Error en el _onGetProductsToEntrada: $e, $s');
    }
  }

//*metodo para obtener los permisos del usuario
  void _onAssignUserToOrder(
      AssignUserToOrder event, Emitter<RecepcionState> emit) async {
    try {
      emit(AssignUserToOrderLoading());
      // final response = await _recepcionRepository.assignUserToOrder(
      //     event.idOrder, event.idUser, event.context);
      // if (response != null && response is bool) {
      //   if (response) {
      //     emit(AssignUserToOrderSuccess());
      //   } else {
      //     emit(AssignUserToOrderFailure('Error al asignar el usuario'));
      //   }
      // } else {
      //   emit(AssignUserToOrderFailure('Error al asignar el usuario'));
      // }
    } catch (e, s) {
      emit(AssignUserToOrderFailure('Error al asignar el usuario'));
      print('Error en el _onAssignUserToOrder: $e, $s');
    }
  }

  //*metodo para buscar una entrada
  void _onSearchOrderEvent(
      SearchOrdenCompraEvent event, Emitter<RecepcionState> emit) async {
    try {
      listFiltersOrdenesCompra = [];
      listFiltersOrdenesCompra = listOrdenesCompra;

      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        listFiltersOrdenesCompra = listOrdenesCompra;
      } else {
        listFiltersOrdenesCompra = listFiltersOrdenesCompra
            .where((element) => element.name!.contains(query))
            .toList();
      }
      emit(SearchOrdenCompraSuccess(listFiltersOrdenesCompra));
    } catch (e, s) {
      emit(SearchOrdenCompraFailure('Error al buscar la orden de compra'));
      print('Error en el _onSearchPedidoEvent: $e, $s');
    }
  }

  //*metodo para obtener las entradas desde wms
  void _onFetchOrdenesCompra(
      FetchOrdenesCompra event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraLoading());
      final response =
          await _recepcionRepository.resBatchsPacking(false, event.context);
      if (response != null && response is List) {
        //todo: agregamos la lista de entradas a la bd
        await db.entradasRepository.insertEntrada(response);
        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<LineasRecepcion> productsToInsert =
            response.expand((batch) => batch.lineasRecepcion!).toList();

        print('productsToInsert: ${productsToInsert.length}');

        // Enviar la lista agrupada a insertBatchProducts
        await db.productEntradaRepository
            .insertarProductoEntrada(productsToInsert);

        print('ordenesCompra: ${response.length}');
        emit(FetchOrdenesCompraSuccess(response));
      } else {
        emit(FetchOrdenesCompraFailure(
            'Error al obtener las ordenes de compra'));
      }
    } catch (e, s) {
      print('Error en RecepcionBloc: $e, $s');
    }
  }

  //*metodo para obtener las entradas desde la bd
  void _onFetchOrdenesCompraOfBd(
      FetchOrdenesCompraOfBd event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraOfBdLoading());
      final listbd = await db.entradasRepository.getAllEntradas();
      if (listbd != null && listbd.isNotEmpty) {
        listOrdenesCompra = listbd;
        listFiltersOrdenesCompra = listbd;
      } else {
        emit(FetchOrdenesCompraOfBdFailure(
            'No hay ordenes de compra en la base de datos'));
      }

      emit(FetchOrdenesCompraOfBdSuccess(listFiltersOrdenesCompra));
    } catch (e, s) {
      emit(FetchOrdenesCompraOfBdFailure(
          'Error al obtener las ordenes de compra'));
      print('Error en el _onFetchOrdenesCompraOfBd: $e, $s');
    }
  }

  //*metodo para ocultar y mostrar el teclado
  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<RecepcionState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //*metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserOrder event, Emitter<RecepcionState> emit) async {
    // try {
    //   emit(ConfigurationLoadingPack());
    //   int userId = await PrefUtils.getUserId();
    //   final response =
    //       await db.configurationsRepository.getConfiguration(userId);

    //   if (response != null) {
    //     configurations = response;
    //     emit(ConfigurationLoadedPack(response));
    //   } else {
    //     emit(ConfigurationErrorPack('Error al cargar configuraciones'));
    //   }
    // } catch (e, s) {
    //   emit(ConfigurationErrorPack(e.toString()));
    //   print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    // }
  }
}
