class PackingRequest {
  final int idBatch;
  // final int idPaquete;
  final bool isSticker;
  final bool isCertificate;
  final double pesoTotalPaquete;
  final List<ListItem> listItem;

  PackingRequest({
    required this.idBatch,
    // required this.idPaquete,
    required this.isSticker,
    required this.isCertificate,
    required this.pesoTotalPaquete,
    required this.listItem,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_batch": idBatch,
      // "id_paquete": idPaquete,
      "is_sticker": isSticker,
      "is_certificate": isCertificate,
      "peso_total_paquete": pesoTotalPaquete,
      "list_item": listItem.map((item) => item.toMap()).toList(),
    };
  }
}

class ListItem {
  final int idMove;
  final int productId;
  final String lote;
  final int locationId;
  final dynamic cantidadSeparada;
  final String observacion;
  final String unidadMedida;
  final int idOperario;
  final String fechaTransaccion;

  ListItem({
    required this.idMove,
    required this.productId,
    required this.lote,
    required this.locationId,
    required this.cantidadSeparada,
    required this.observacion,
    required this.unidadMedida,
    required this.idOperario,
    required this.fechaTransaccion,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_move": idMove,
      "product_id": productId,
      "lote": lote,
      "location_id": locationId,
      "cantidad_separada": cantidadSeparada,
      "observacion": observacion,
      "unidad_medida": unidadMedida,
      "id_operario": idOperario,
      "fecha_transaccion": fechaTransaccion,
    };
  }
}
