class Item {
  int idMove;
  int productId;
  String lote;
  int cantidad;
  String novedad;
  double timeLine;
  int muelle;
  int idOperario;

  Item({
    required this.idMove,
    required this.productId,
    required this.lote,
    required this.cantidad,
    required this.novedad,
    required this.timeLine,
    required this.muelle,
    required this.idOperario,
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
    };
  }
}
