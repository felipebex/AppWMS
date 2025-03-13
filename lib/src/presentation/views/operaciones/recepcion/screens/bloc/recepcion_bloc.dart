// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';

part 'recepcion_event.dart';
part 'recepcion_state.dart';

class RecepcionBloc extends Bloc<RecepcionEvent, RecepcionState> {
  //listado de ordenes de compra
  List<OrdenCompra> listOrdenesCompra = [];
  List<OrdenCompra> listFiltersOrdenesCompra = [];
  //repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();
  //controller de busqueda
  TextEditingController searchControllerOrderC = TextEditingController();
  bool isKeyboardVisible = false;

  RecepcionBloc() : super(RecepcionInitial()) {
    on<RecepcionEvent>((event, emit) {});
    //*obtener todas las ordenes de compra
    on<FetchOrdenesCompra>(_onFetchOrdenesCompra);
    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //* buscar una orden de compra
    on<SearchOrdenCompraEvent>(_onSearchPedidoEvent);
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
}
