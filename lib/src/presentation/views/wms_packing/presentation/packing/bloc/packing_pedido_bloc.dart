import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'packing_pedido_event.dart';
part 'packing_pedido_state.dart';

class PackingPedidoBloc extends Bloc<PackingPedidoEvent, PackingPedidoState> {
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();
  TextEditingController searchControllerPedido = TextEditingController();
  TextEditingController searchControllerProduct = TextEditingController();
  TextEditingController controllerTemperature = TextEditingController();

  PackingPedidoBloc() : super(PackingPedidoInitial()) {
    on<PackingPedidoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
