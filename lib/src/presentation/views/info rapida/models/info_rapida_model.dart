// To parse this JSON data, do
//
//     final infoRapida = infoRapidaFromMap(jsonString);

import 'dart:convert';

import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

InfoRapida infoRapidaFromMap(String str) =>
    InfoRapida.fromMap(json.decode(str));

String infoRapidaToMap(InfoRapida data) => json.encode(data.toMap());

class InfoRapida {
  String? jsonrpc;
  dynamic id;
  InfoRapidaResult? result;

  InfoRapida({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory InfoRapida.fromMap(Map<String, dynamic> json) => InfoRapida(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null
            ? null
            : InfoRapidaResult.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class InfoRapidaResult {
  int? code;
  String? type;
  String? msg;
  InfoResult? result;

  InfoRapidaResult({
    this.code,
    this.msg,
    this.type,
    this.result,
  });

  factory InfoRapidaResult.fromMap(Map<String, dynamic> json) =>
      InfoRapidaResult(
        code: json["code"],
        msg: json["msg"],
        type: json["type"],
        result:
            json["result"] == null ? null : InfoResult.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "type": type,
        "result": result?.toMap(),
      };
}

class InfoResult {
  int? id;
  String? nombre;
  dynamic? precio;
  String? referencia;
  dynamic? peso;
  dynamic? volumen;
  dynamic? codigoBarras;
  dynamic? cantidadDisponible;
  dynamic? previsto;
  // List<Barcodes>? codigosBarrasPaquetes;
  String? categoria;
  List<Ubicacion>? ubicaciones;

  //parametros de ubicacion
  String? ubicacionPadre;
  String? tipoUbicacion;
  List<Producto>? productos;

  InfoResult({
    this.id,
    this.nombre,
    this.precio,
    this.cantidadDisponible,
    this.previsto,
    this.referencia,
    this.peso,
    this.volumen,
    this.codigoBarras,
    // this.codigosBarrasPaquetes,
    this.categoria,
    this.ubicaciones,
    this.ubicacionPadre,
    this.tipoUbicacion,
    this.productos,
  });

  factory InfoResult.fromMap(Map<String, dynamic> json) => InfoResult(
        id: json["id"],
        nombre: json["nombre"],
        precio: json["precio"],
        cantidadDisponible: json["cantidad_disponible"],
        previsto: json["previsto"],
        referencia: json["referencia"],
        peso: json["peso"],
        volumen: json["volumen"],
        codigoBarras: json["codigo_barras"],
        // codigosBarrasPaquetes: json["codigos_barras_paquetes"] == null
        //     ? []
        //     : List<Barcodes>.from(
        //         json["codigos_barras_paquetes"]!.map((x) => x)),
        categoria: json["categoria"],
        ubicaciones: json["ubicaciones"] == null
            ? []
            : List<Ubicacion>.from(
                json["ubicaciones"]!.map((x) => Ubicacion.fromMap(x))),

        //parametros de ubicacion
        ubicacionPadre: json["ubicacion_padre"],
        tipoUbicacion: json["tipo_ubicacion"],
        productos: json["productos"] == null
            ? []
            : List<Producto>.from(
                json["productos"]!.map((x) => Producto.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
        "precio": precio,
        "cantidad_disponible": cantidadDisponible,
        "previsto": previsto,
        "referencia": referencia,
        "peso": peso,
        "volumen": volumen,
        "codigo_barras": codigoBarras,
        // "codigos_barras_paquetes": codigosBarrasPaquetes == null
        //     ? []
        //     : List<dynamic>.from(codigosBarrasPaquetes!.map((x) => x)),
        "categoria": categoria,
        "ubicaciones": ubicaciones == null
            ? []
            : List<dynamic>.from(ubicaciones!.map((x) => x.toMap())),
        "ubicacion_padre": ubicacionPadre,
        "tipo_ubicacion": tipoUbicacion,
        "productos": productos == null
            ? []
            : List<dynamic>.from(productos!.map((x) => x.toMap())),
      };
}

class Ubicacion {

  int? idMove;
  int? idAlmacen;
  int? idUbicacion;
  String? ubicacion;
  dynamic? cantidad;
  dynamic? reservado;
  dynamic? catidadMano;
  String? codigoBarras;
  String? lote;
  dynamic? loteId;
  String? fechaEliminacion;
  String? fechaEntrada;

  Ubicacion({
    this.idMove,
    this.idAlmacen,
    this.idUbicacion,
    this.ubicacion,
    this.cantidad,
    this.reservado,
    this.catidadMano,
    this.codigoBarras,
    this.lote,
    this.loteId,
    this.fechaEliminacion,
    this.fechaEntrada,
  });

  factory Ubicacion.fromMap(Map<String, dynamic> json) => Ubicacion(
        idAlmacen:  json["id_almacen"],
        idMove: json["id_move"],
        idUbicacion: json["id_ubicacion"],
        ubicacion: json["ubicacion"],
        cantidad: json["cantidad"],
        reservado: json["reservado"],
        catidadMano: json["catidad_mano"],
        codigoBarras: json["codigo_barras"],
        lote: json["lote"],
        loteId: json["lote_id"],
        fechaEliminacion: json["fecha_eliminacion"],
        fechaEntrada: json["fecha_entrada"],
      );

  Map<String, dynamic> toMap() => {
        "id_move" : idMove,
        "id_almacen": idAlmacen,
        "id_ubicacion": idUbicacion,
        "ubicacion": ubicacion,
        "cantidad": cantidad,
        "reservado": reservado,
        "catidad_mano": catidadMano,
        "codigo_barras": codigoBarras,
        "lote": lote,
        "lote_id": loteId,
        "fecha_eliminacion": fechaEliminacion,
        "fecha_entrada": fechaEntrada,
      };
}

class Producto {
  int? id;
  String? producto;
  dynamic? cantidad;
  dynamic? codigoBarras;
  dynamic? lotId;
  String? lote;

  Producto({
    this.id,
    this.producto,
    this.cantidad,
    this.codigoBarras,
    this.lotId,
    this.lote,
  });

  factory Producto.fromMap(Map<String, dynamic> json) => Producto(
        id: json["id"],
        producto: json["producto"],
        cantidad: json["cantidad"],
        codigoBarras: json["codigo_barras"],
        lotId: json["lot_id"],
        lote: json["lote"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "producto": producto,
        "cantidad": cantidad,
        "codigo_barras": codigoBarras,
        "lot_id": lotId,
        "lote": lote,
      };
}
