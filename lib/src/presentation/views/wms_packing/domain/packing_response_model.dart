import 'dart:convert';

import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';

class PackingModelResponse {
    final String? jsonrpc;
    final dynamic id;
    final PackingModelResponseResult? result;

    PackingModelResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory PackingModelResponse.fromJson(String str) => PackingModelResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PackingModelResponse.fromMap(Map<String, dynamic> json) => PackingModelResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : PackingModelResponseResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class PackingModelResponseResult {
    final int? code;
    final List<BatchPackingModel>? result;

    PackingModelResponseResult({
        this.code,
        this.result,
    });

    factory PackingModelResponseResult.fromJson(String str) => PackingModelResponseResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PackingModelResponseResult.fromMap(Map<String, dynamic> json) => PackingModelResponseResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<BatchPackingModel>.from(json["result"]!.map((x) => BatchPackingModel.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}




class BatchPackingModel {
  final int? id;
  final String? name;
  final dynamic scheduleddate;
  final dynamic pickingTypeId;
  final String? state;
  final dynamic userId;
  final List<PedidoPacking>? listaPedidos;
  final int? cantidadPedidos;

  final int? isSeparate;
  final dynamic isSelected;
  final dynamic isPacking;
  final String? userName;

  final int? pedidoSeparateQty; //cantidad que se lleva separada

  final double? timeSeparateTotal;
  final String? timeSeparateStart;
  final String? timeSeparateEnd;

  BatchPackingModel({
    this.id,
    this.name,
    this.scheduleddate,
    this.cantidadPedidos,
    this.state,
    this.userId,
    this.userName,
    this.pickingTypeId,
    this.listaPedidos,
    this.isSeparate,
    this.isSelected,
    this.isPacking,
    this.pedidoSeparateQty,
    this.timeSeparateTotal,
    this.timeSeparateStart,
    this.timeSeparateEnd,
  });

  factory BatchPackingModel.fromJson(String str) =>
      BatchPackingModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatchPackingModel.fromMap(Map<String, dynamic> json) =>
      BatchPackingModel(
        id: json["id"],
        name: json["name"],
        scheduleddate: json["scheduleddate"],
        cantidadPedidos: json["catidad_pedidos"],
        userName: json['user_name'],
        state: json["state"],
        userId: json["user_id"],
        pickingTypeId: json["picking_type_id"],
        listaPedidos: json["lista_pedidos"] == null
            ? []
            : List<PedidoPacking>.from(
                json["lista_pedidos"]!.map((x) => PedidoPacking.fromMap(x))),
        isSeparate: json["is_separate"],
        isSelected: json["is_selected"],
        isPacking: json["is_packing"],
        pedidoSeparateQty: json["pedido_separate_qty"],
        timeSeparateTotal: json["time_separate_total"],
        timeSeparateStart: json["time_separate_start"],
        timeSeparateEnd: json["time_separate_end"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "scheduleddate": scheduleddate,
        "catidad_pedidos": cantidadPedidos,
        "state": state,
        "user_id": userId,
        "picking_type_id": pickingTypeId,
        "lista_pedidos": listaPedidos == null
            ? []
            : List<dynamic>.from(listaPedidos!.map((x) => x.toMap())),
        "is_separate": isSeparate,
        "is_selected": isSelected,
        "is_packing": isPacking,
        "pedido_separate_qty": pedidoSeparateQty,
        "time_separate_total": timeSeparateTotal,
        "time_separate_start": timeSeparateStart,
        "time_separate_end": timeSeparateEnd,
      };
}

class PedidoPacking {
  final int? id;
  final int? batchId;
  final String? name;
  final dynamic referencia;
  final DateTime? fecha;
  final int? isSelected;
  final int? isPacking;
  final dynamic? contacto;
  final String? tipoOperacion;
  final String? contactoName;
  final int? isTerminate;
  final int? cantidadProductos;
  final int? numeroPaquetes;
  final List<PorductoPedido>? listaProductos;
  final List<Paquete>? listaPaquetes;

  PedidoPacking({
    this.id,
    this.isSelected,
    this.isPacking,
    this.batchId,
    this.name,
    this.referencia,
    this.fecha,
    this.contacto,
    this.tipoOperacion,
    this.cantidadProductos,
    this.numeroPaquetes,
    this.listaProductos,
    this.listaPaquetes,
    this.isTerminate,
    this.contactoName,
  });

  factory PedidoPacking.fromJson(String str) =>
      PedidoPacking.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PedidoPacking.fromMap(Map<String, dynamic> json) => PedidoPacking(
        id: json["id"],
        isSelected: json["is_selected"],
        isPacking: json["is_packing"],
        batchId: json["batch_id"],
        name: json["name"],
        referencia: json["referencia"],
        fecha: json["fecha"] == null
            ? DateTime.now()
            : DateTime.parse(json["fecha"]),
        contacto: json["contacto"],
        contactoName: json["contacto_name"],
        tipoOperacion: json["tipo_operacion"],
        cantidadProductos: json["cantidad_productos"],
        numeroPaquetes: json["numero paquetes"],
        listaProductos: json["lista_productos"] == null
            ? []
            : List<PorductoPedido>.from(
                json["lista_productos"]!.map((x) => PorductoPedido.fromMap(x))),
        listaPaquetes: json["lista_paquetes"] == null
            ? []
            : List<Paquete>.from(
                json["lista_paquetes"]!.map((x) => Paquete.fromMap(x))),
        isTerminate: json["is_terminate"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "is_selected": isSelected,
        "is_packing": isPacking,
        "batch_id": batchId,
        "name": name,
        "referencia": referencia,
        "fecha": fecha?.toIso8601String(),
        "contacto": contacto,
        "contacto_name": contactoName,
        "tipo_operacion": tipoOperacion,
        "cantidad_productos": cantidadProductos,
        "numero paquetes": numeroPaquetes,
        "lista_productos": listaProductos == null
            ? []
            : List<dynamic>.from(listaProductos!.map((x) => x.toMap())),
        "lista_paquetes": listaPaquetes == null
            ? []
            : List<dynamic>.from(listaPaquetes!.map((x) => x.toMap())),
        "is_terminate": isTerminate,
      };
}

class Paquete {
  final int? id;
  final String? name;
  final int? batchId;
  final int? pedidoId;
  final int? cantidadProductos;
  final List<dynamic>? listaProductos;
  final bool? isSticker;
  // final DateTime? fechaCreacion;
  // final DateTime? fechaActualiazacion;

  Paquete({
    this.id,
    this.name,
    this.batchId,
    this.pedidoId,
    this.cantidadProductos,
    this.listaProductos,
    this.isSticker,
    // this.fechaCreacion,
    // this.fechaActualiazacion,
  });

  factory Paquete.fromJson(String str) => Paquete.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Paquete.fromMap(Map<String, dynamic> json) => Paquete(
      id: json["id"],
      name: json["name"],
      batchId: json["batch_id"],
      pedidoId: json["pedido_id"],
      cantidadProductos: json["cantidad_productos"],
      listaProductos: json["lista_productos"] == null
          ? []
          : List<dynamic>.from(json["lista_productos"]!.map((x) => x)),
      isSticker: json["is_sticker"]
      // fechaCreacion: json["fecha_creacion"] == null ? null : DateTime.parse(json["fecha_creacion"]),
      // fechaActualiazacion: json["fecha_actualiazacion"] == null ? null : DateTime.parse(json["fecha_actualiazacion"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "batch_id": batchId,
        "pedido_id": pedidoId,
        "cantidad_productos": cantidadProductos,
        "lista_productos": listaProductos == null
            ? []
            : List<dynamic>.from(listaProductos!.map((x) => x)),
        "is_sticker": isSticker,
        // "fecha_creacion"
        // "fecha_actualiazacion": "${fechaActualiazacion!.year.toString().padLeft(4, '0')}-${fechaActualiazacion!.month.toString().padLeft(2, '0')}-${fechaActualiazacion!.day.toString().padLeft(2, '0')}",
      };
}

// class ListaProducto {
//   final int? productId;
//   final int? batchId;
//   final int? pedidoId;
//   final List<dynamic>? idProduct;
//   final int? loteId;
//   final dynamic lotId;
//   final List<dynamic>? locationId;
//   final List<dynamic>? locationDestId;
//   final double? quantity;
//   final String? tracking;
//   final dynamic barcode;
//   final List<ProductPacking>? productPacking;
//   final dynamic weight;
//   final String? unidades;

//   ListaProducto({
//     this.productId,
//     this.batchId,
//     this.pedidoId,
//     this.idProduct,
//     this.loteId,
//     this.lotId,
//     this.locationId,
//     this.locationDestId,
//     this.quantity,
//     this.tracking,
//     this.barcode,
//     this.productPacking,
//     this.weight,
//     this.unidades,
//   });

//   factory ListaProducto.fromJson(String str) =>
//       ListaProducto.fromMap(json.decode(str));

//   String toJson() => json.encode(toMap());

//   factory ListaProducto.fromMap(Map<String, dynamic> json) => ListaProducto(
//       productId: json["product_id"],
//       batchId: json["batch_id"],
//       pedidoId: json["pedido_id"],
//       idProduct: json["id_product"] == null
//           ? []
//           : List<dynamic>.from(json["id_product"]!.map((x) => x)),
//       loteId: json["lote_id"],
//       lotId: json["lot_id"],
//       locationId: json["location_id"] == null
//           ? []
//           : List<dynamic>.from(json["location_id"]!.map((x) => x)),
//       locationDestId: json["location_dest_id"] == null
//           ? []
//           : List<dynamic>.from(json["location_dest_id"]!.map((x) => x)),
//       quantity: json["quantity"],
//       tracking: json["tracking"],
//       barcode: json["barcode"],
//       productPacking: json["product_packing"] == null
//           ? []
//           : List<ProductPacking>.from(
//               json["product_packing"]!.map((x) => ProductPacking.fromMap(x))),
//       weight: json["weight"],
//       unidades: json["unidades"]);

//   Map<String, dynamic> toMap() => {
//         "product_id": productId,
//         "batch_id": batchId,
//         "pedido_id": pedidoId,
//         "id_product": idProduct == null
//             ? []
//             : List<dynamic>.from(idProduct!.map((x) => x)),
//         "lote_id": loteId,
//         "lot_id": lotId,
//         "location_id": locationId == null
//             ? []
//             : List<dynamic>.from(locationId!.map((x) => x)),
//         "location_dest_id": locationDestId == null
//             ? []
//             : List<dynamic>.from(locationDestId!.map((x) => x)),
//         "quantity": quantity,
//         "tracking": tracking,
//         "barcode": barcode,
//         "product_packing": productPacking == null
//             ? []
//             : List<dynamic>.from(productPacking!.map((x) => x.toMap())),
//         "weight": weight,
//         "unidades": unidades
//       };
// }

// class ProductPacking {
//   final dynamic barcode;
//   final double? cantidad;

//   ProductPacking({
//     this.barcode,
//     this.cantidad,
//   });

//   factory ProductPacking.fromJson(String str) =>
//       ProductPacking.fromMap(json.decode(str));

//   String toJson() => json.encode(toMap());

//   factory ProductPacking.fromMap(Map<String, dynamic> json) => ProductPacking(
//         barcode: json["barcode"],
//         cantidad: json["cantidad"],
//       );

//   Map<String, dynamic> toMap() => {
//         "barcode": barcode,
//         "cantidad": cantidad,
//       };
// }
