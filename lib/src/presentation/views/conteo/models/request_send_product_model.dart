
class ConteoItem {
  final int orderId;
  final String lineId;
  final dynamic quantityCounted;
  final String observation;
  final int timeLine;
  final String fechaTransaccion;
  final int idOperario;
  final int productId;
  final dynamic locationId;
  final dynamic loteId;

  ConteoItem({
    required this.orderId,
    required this.lineId,
    required this.quantityCounted,
    required this.observation,
    required this.timeLine,
    required this.fechaTransaccion,
    required this.idOperario,
    required this.productId,
    required this.locationId,
    required this.loteId, 
  });

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "line_id": lineId,
      "quantity_counted": quantityCounted,
      "observation": observation,
      "time_line": timeLine,
      "fecha_transaccion": fechaTransaccion,
      "id_operario": idOperario,
      "product_id": productId,
      "location_id": locationId,
      "lote_id": loteId,
    };
  }
}

