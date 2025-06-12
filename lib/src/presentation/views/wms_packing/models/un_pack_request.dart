class UnPackRequest {
  final int idTransferencia;
  final int idPaquete;
  final List<ListItemUnpack> listItems;

  UnPackRequest({
    required this.idTransferencia,
    required this.idPaquete,
    required this.listItems,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_transferencia": idTransferencia,
      "id_paquete": idPaquete,
      "list_items": listItems.map((item) => item.toMap()).toList(),
    };
  }
}


class ListItemUnpack {
  final int idMove;
  // final int productId;
  // final dynamic lote;
  // final int locationId;
  // final dynamic cantidadSeparada;
  final String observacion;
  final int idOperario;

  ListItemUnpack({
    required this.idMove,
    // required this.productId,
    // required this.lote,
    // required this.locationId,
    // required this.cantidadSeparada,
    required this.observacion,
    required this.idOperario,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_move": idMove,
      // "product_id": productId,
      // "lote": lote,
      // "location_id": locationId,
      // "cantidad_separada": cantidadSeparada,
      "observacion": observacion,
      "id_operario": idOperario,
    };
  }
}
