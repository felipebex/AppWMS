import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/transferencias/data/transferencias_repository.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';

part 'transferencia_event.dart';
part 'transferencia_state.dart';

class TransferenciaBloc extends Bloc<TransferenciaEvent, TransferenciaState> {
  //*controller de busqueda
  TextEditingController searchControllerTransfer = TextEditingController();
  //*variables para validar
  bool isKeyboardVisible = false;

  //*repositorio
  final TransferenciasRepository _transferenciasRepository =
      TransferenciasRepository();

  //lista de transferencias
  List<ResultTransFerencias> transferencias = [];

  TransferenciaBloc() : super(TransferenciaInitial()) {
    on<TransferenciaEvent>((event, emit) {});
    //metodo para obtener todas las transferencias
    on<FetchAllTransferencias>(_onfetchTransferencias);
  }

  //metodo para traer todas las transferencias
  _onfetchTransferencias(
      FetchAllTransferencias event, Emitter<TransferenciaState> emit) async {
    try {
      emit(TransferenciaLoading());
      transferencias.clear();
      final response =
          await _transferenciasRepository.fetAllTransferencias(true);
      if (response.isNotEmpty) {
        transferencias = response;
        emit(TransferenciaLoaded(transferencias));
      } else {
        emit(TransferenciaError('No se encontraron transferencias'));
      }
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }






}
