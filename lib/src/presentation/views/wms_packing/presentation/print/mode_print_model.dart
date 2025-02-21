import 'dart:convert';

class PrintModel {
  final String? batchName;
  final int? batchId;
  final String? pickingTypeId;
  final int? cantidadPedidos;
  final String? namePedido;
  final String? referencia;
  final dynamic? contacto;
  final String? contactoName;
  final String? tipoOperacion;
  final int? cantidadProductos;
  final int? numeroPaquetes;
  final int? idPaquete;
  final String? namePaquete;
  final int? cantProductoPack;

  PrintModel({
    this.batchName,
    this.batchId,
    this.pickingTypeId,
    this.cantidadPedidos,
    this.namePedido,
    this.referencia,
    this.contacto,
    this.contactoName,
    this.tipoOperacion,
    this.cantidadProductos,
    this.numeroPaquetes,
    this.idPaquete,
    this.namePaquete,
    this.cantProductoPack,
  });

  factory PrintModel.fromJson(String str) =>
      PrintModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PrintModel.fromMap(Map<String, dynamic> json) => PrintModel(
        batchName: json["batch_name"],
        batchId: json["batch_id"],
        pickingTypeId: json["picking_type_id"],
        cantidadPedidos: json["cantidad_pedidos"],
        namePedido: json["name_pedido"],
        referencia: json["referencia"],
        contacto: json["contacto"],
        contactoName: json["contacto_name"],
        tipoOperacion: json["tipo_operacion"],
        cantidadProductos: json["cantidad_productos"],
        numeroPaquetes: json["numero_paquetes"],
        idPaquete: json["id_paquete"],
        namePaquete: json["name_paquete"],
        cantProductoPack: json["cant_producto_pack"],
      );

  Map<String, dynamic> toMap() => {
        "batch_name": batchName,
        "batch_id": batchId,
        "picking_type_id": pickingTypeId,
        "cantidad_pedidos": cantidadPedidos,
        "name_pedido": namePedido,
        "referencia": referencia,
        "contacto": contacto,
        "contacto_name": contactoName,
        "tipo_operacion": tipoOperacion,
        "cantidad_productos": cantidadProductos,
        "numero_paquetes": numeroPaquetes,
        "id_paquete": idPaquete,
        "name_paquete": namePaquete,
        "cant_producto_pack": cantProductoPack,
      };
}
