class RecepcionRequest {
  final int idRecepcion;
  final List<ListItem> listItems;

  RecepcionRequest({
    required this.idRecepcion,
    required this.listItems,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_recepcion": idRecepcion,
      "list_items": listItems.map((item) => item.toMap()).toList(),
    };
  }
}

class ListItem {
  final int idProducto;
  final int idMove;
  final int loteProducto;

  final int ubicacionDestino;
  final int cantidadSeparada;
  final String observacion;
  final int idOperario;
  final String fechaTransaccion;
  final int timeLine;

  ListItem({
    required this.idProducto,
    required this.idMove,
    required this.loteProducto,
    required this.ubicacionDestino,
    required this.cantidadSeparada,
    required this.observacion,
    required this.idOperario,
    required this.fechaTransaccion,
    required this.timeLine,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_producto": idProducto,
      "id_move": idMove,
      "lote_producto": loteProducto,
      "ubicacion_destino": ubicacionDestino,
      "cantidad_separada": cantidadSeparada,
      "id_operario": idOperario,
      "fecha_transaccion": fechaTransaccion,
      "observacion": observacion,
      "time_line": timeLine,
    };
  }
}
