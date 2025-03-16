// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';

part 'recepcion_event.dart';
part 'recepcion_state.dart';

class RecepcionBloc extends Bloc<RecepcionEvent, RecepcionState> {
  //listado de ordenes de compra
  List<ResultEntrada> listOrdenesCompra = [];
  List<ResultEntrada> listFiltersOrdenesCompra = [];
  //repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();
  //controller de busqueda
  TextEditingController searchControllerOrderC = TextEditingController();

  //variables para scan valdiar
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

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  RecepcionBloc() : super(RecepcionInitial()) {
    on<RecepcionEvent>((event, emit) {});
    //*obtener todas las ordenes de compra
    on<FetchOrdenesCompra>(_onFetchOrdenesCompra);
    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //* buscar una orden de compra
    on<SearchOrdenCompraEvent>(_onSearchPedidoEvent);

    //*asignar un usuario a una orden de compra
    on<AssignUserToOrder>(_onAssignUserToOrder);
    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserOrder>(_onLoadConfigurationsUserEvent);
  }

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

  void _onSearchPedidoEvent(
      SearchOrdenCompraEvent event, Emitter<RecepcionState> emit) async {
    try {
      listFiltersOrdenesCompra = [];
      listFiltersOrdenesCompra = listOrdenesCompra;

      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        listFiltersOrdenesCompra = listOrdenesCompra;
      } else {
        listFiltersOrdenesCompra = listFiltersOrdenesCompra
            .where((element) => element.purchaseOrderName!.contains(query))
            .toList();
      }
      emit(SearchOrdenCompraSuccess(listFiltersOrdenesCompra));
    } catch (e, s) {
      emit(SearchOrdenCompraFailure('Error al buscar la orden de compra'));
      print('Error en el _onSearchPedidoEvent: $e, $s');
    }
  }

  void _onFetchOrdenesCompra(
      FetchOrdenesCompra event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraLoading());
      final response =
          await _recepcionRepository.resBatchsPacking(false, event.context);
      if (response != null && response is List) {
        listOrdenesCompra = response;
        listFiltersOrdenesCompra = response;
        print('ordenesCompra: ${listFiltersOrdenesCompra.length}');
        emit(FetchOrdenesCompraSuccess(listFiltersOrdenesCompra));
      } else {
        emit(FetchOrdenesCompraFailure(
            'Error al obtener las ordenes de compra'));
      }
    } catch (e, s) {
      print('Error en RecepcionBloc: $e, $s');
    }
  }

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
