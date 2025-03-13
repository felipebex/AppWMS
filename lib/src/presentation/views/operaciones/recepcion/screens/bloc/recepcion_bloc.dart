// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';

part 'recepcion_event.dart';
part 'recepcion_state.dart';

class RecepcionBloc extends Bloc<RecepcionEvent, RecepcionState> {
  //listado de ordenes de compra
  List<OrdenCompra> ordenesCompra = [];
  //repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();

  RecepcionBloc() : super(RecepcionInitial()) {
    on<RecepcionEvent>((event, emit) {});

    on<FetchOrdenesCompra>(_onFetchOrdenesCompra);
  }
  void _onFetchOrdenesCompra(
      FetchOrdenesCompra event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraLoading());
      final response =
          await _recepcionRepository.resBatchsPacking(false, event.context);
      if (response != null && response is List) {
        ordenesCompra = response;
        print('ordenesCompra: ${ordenesCompra.length}');
        emit(FetchOrdenesCompraSuccess(ordenesCompra));
      } else {
        emit(FetchOrdenesCompraFailure(
            'Error al obtener las ordenes de compra'));
      }
    } catch (e, s) {
      print('Error en RecepcionBloc: $e, $s');
    }
  }
}
