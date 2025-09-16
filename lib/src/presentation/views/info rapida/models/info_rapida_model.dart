// To parse this JSON data, do
//
//     final infoRapida = infoRapidaFromMap(jsonString);

import 'dart:convert';


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
  dynamic precio;
  String? referencia;
  dynamic peso;
  dynamic volumen;
  dynamic codigoBarras;
  dynamic cantidadDisponible;
  dynamic previsto;
  // List<Barcodes>? codigosBarrasPaquetes;
  String? categoria;
  List<Ubicacion>? ubicaciones;
  String? unidadMedida;


  dynamic? isSticker;
  dynamic? isCertificate;
  String? fechaEmpaquetado;

  //parametros de ubicacion
  String? ubicacionPadre;
  String? tipoUbicacion;
  List<Producto>? productos;
  dynamic? numeroPedidos;
  dynamic? totalProductos;
  dynamic? numeroProductos;

  String? nombreAlmacen;




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
    this.unidadMedida,
    this.isSticker,
    this.isCertificate,
    this.fechaEmpaquetado,
    this.numeroPedidos,
    this.totalProductos,
    this.numeroProductos,
    this.nombreAlmacen,
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
        unidadMedida: json["unidad_medida"],
        productos: json["productos"] == null
            ? []
            : List<Producto>.from(
                json["productos"]!.map((x) => Producto.fromMap(x))),
        isSticker: json["is_sticker"],
        isCertificate: json["is_certificate"],
        fechaEmpaquetado: json["fecha_empaquetado"],
        numeroPedidos: json["numero_pedidos"],
        totalProductos: json["total_productos"],
        numeroProductos: json["numero_productos"],
        nombreAlmacen: json["nombre_almacen"],
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
        "unidad_medida": unidadMedida,
        "productos": productos == null
            ? []
            : List<dynamic>.from(productos!.map((x) => x.toMap())),
        "is_sticker": isSticker,
        "is_certificate": isCertificate,
        "fecha_empaquetado": fechaEmpaquetado,
        "numero_pedidos": numeroPedidos,
        "total_productos": totalProductos,
        "numero_productos": numeroProductos,
        "nombre_almacen": nombreAlmacen,
      };
}

class Ubicacion {
  int? idMove;
  int? idAlmacen;
  int? idUbicacion;
  String? ubicacion;
  dynamic cantidad;
  dynamic reservado;
  dynamic cantidadMano;
  String? codigoBarras;
  String? lote;
  dynamic loteId;
  String? fechaEliminacion;
  String? fechaEntrada;
  String? unidadMedida;

  Ubicacion({
    this.idMove,
    this.idAlmacen,
    this.idUbicacion,
    this.ubicacion,
    this.cantidad,
    this.reservado,
    this.cantidadMano,
    this.codigoBarras,
    this.lote,
    this.loteId,
    this.fechaEliminacion,
    this.fechaEntrada,
    this.unidadMedida,
  });

  factory Ubicacion.fromMap(Map<String, dynamic> json) => Ubicacion(
        idAlmacen: json["id_almacen"],
        idMove: json["id_move"],
        idUbicacion: json["id_ubicacion"],
        ubicacion: json["ubicacion"],
        cantidad: json["cantidad"],
        reservado: json["reservado"],
        cantidadMano: json["cantidad_mano"],
        codigoBarras: json["codigo_barras"],
        lote: json["lote"],
        loteId: json["lote_id"],
        fechaEliminacion: json["fecha_eliminacion"],
        fechaEntrada: json["fecha_entrada"],
        unidadMedida: json["unidad_medida"],
      );

  Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "id_almacen": idAlmacen,
        "id_ubicacion": idUbicacion,
        "ubicacion": ubicacion,
        "cantidad": cantidad,
        "reservado": reservado,
        "cantidad_mano": cantidadMano,
        "codigo_barras": codigoBarras,
        "lote": lote,
        "lote_id": loteId,
        "fecha_eliminacion": fechaEliminacion,
        "fecha_entrada": fechaEntrada,
        "unidad_medida": unidadMedida,
      };
}

class Producto {
  int? id;
  String? producto;
  dynamic cantidad;
  dynamic codigoBarras;
  dynamic lotId;
  String? lote;
  String? unidadMedida;
  String? pedido;
  String? origin;
  String? tercero;
  String? numeroCaja;
  String? nombreAlmacen;

  Producto({
    this.id,
    this.producto,
    this.cantidad,
    this.codigoBarras,
    this.lotId,
    this.lote,
    this.unidadMedida,
    this.pedido,
    this.origin,
    this.tercero,
    this.numeroCaja,
    this.nombreAlmacen,

    
  });

  factory Producto.fromMap(Map<String, dynamic> json) => Producto(
        id: json["id"],
        producto: json["producto"],
        cantidad: json["cantidad"],
        codigoBarras: json["codigo_barras"],
        lotId: json["lot_id"],
        lote: json["lote"],
        unidadMedida: json["unidad_medida"],
        pedido: json["pedido"],
        origin: json["origin"],
        tercero: json["tercero"],
        numeroCaja: json["numero_caja"],
        nombreAlmacen: json["nombre_almacen"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "producto": producto,
        "cantidad": cantidad,
        "codigo_barras": codigoBarras,
        "lot_id": lotId,
        "lote": lote,
        "unidad_medida": unidadMedida,
        "pedido": pedido,
        "origin": origin,
        "tercero": tercero,
        "numero_caja": numeroCaja,
        "nombre_almacen": nombreAlmacen,
      };
}
