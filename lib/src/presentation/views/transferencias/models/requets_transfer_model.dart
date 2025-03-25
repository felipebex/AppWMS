class TransferRequest {
  final int idTransferencia;
  final List<ListItem> listItems;

  TransferRequest({
    required this.idTransferencia,
    required this.listItems,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_transferencia": idTransferencia,
      "list_items": listItems.map((item) => item.toMap()).toList(),
    };
  }
}

class ListItem {
  final int idMove;
  final int idProducto;
  final int idLote;
  final int idUbicacionOrigen;
  final int idUbicacionDestino;
  final int cantidadEnviada;
  final int idOperario;
  final int timeLine;
  final String fechaTransaccion;
  final String observacion;
  final bool dividida;


  ListItem({
    required this.idMove,
    required this.idProducto,
    required this.idLote,
    required this.idUbicacionOrigen,
    required this.idUbicacionDestino,
    required this.cantidadEnviada,
    required this.idOperario,
    required this.timeLine,
    required this.fechaTransaccion,
    required this.observacion,
    required this.dividida,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_move": idMove,
      "id_producto": idProducto,
      "id_lote": idLote,
      "id_ubicacion_origen": idUbicacionOrigen,
      "id_ubicacion_destino": idUbicacionDestino,
      "cantidad_enviada": cantidadEnviada,
      "id_operario": idOperario,
      "time_line": timeLine,
      "fecha_transaccion": fechaTransaccion,
      "observacion": observacion,
      "dividida": dividida,
    };
  }
}
