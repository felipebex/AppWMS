class Item {
  int idMove;
  int productId;
  String lote;
  dynamic cantidad;
  String novedad;
  double timeLine;
  int muelle;
  int idOperario;
  String fechaTransaccion;

  Item({
    required this.idMove,
    required this.productId,
    required this.lote,
    required this.cantidad,
    required this.novedad,
    required this.timeLine,
    required this.muelle,
    required this.idOperario,
    required this.fechaTransaccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_move': idMove,
      'product_id': productId,
      'lote': lote,
      'cantidad': cantidad,
      'novedad': novedad,
      'time_line': timeLine,
      'muelle':  muelle,
      'id_operario': idOperario,
      'fecha_transaccion': fechaTransaccion,
    };
  }
}
