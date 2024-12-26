class PackingRequest {
  final int idBatch;
  final int idPaquete;
  final bool isPackage;
  final double pesoTotalPaquete;
  final List<ListItem> listItem;

  PackingRequest({
    required this.idBatch,
    required this.idPaquete,
    required this.isPackage,
    required this.pesoTotalPaquete,
    required this.listItem,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_batch": idBatch,
      "id_paquete": idPaquete,
      "is_package": isPackage,
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
  final int cantidadSeparada;
  final String observacion;
  final String unidadMedida;

  ListItem({
    required this.idMove,
    required this.productId,
    required this.lote,
    required this.locationId,
    required this.cantidadSeparada,
    required this.observacion,
    required this.unidadMedida,
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
    };
  }
}
