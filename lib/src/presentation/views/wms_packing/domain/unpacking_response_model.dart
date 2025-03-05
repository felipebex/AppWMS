// ignore_for_file: unnecessary_question_mark

import 'dart:convert';

class UnPacking {
    final String? jsonrpc;
    final dynamic id;
    final UnPackingResult? result;

    UnPacking({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory UnPacking.fromJson(String str) => UnPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UnPacking.fromMap(Map<String, dynamic> json) => UnPacking(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : UnPackingResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class UnPackingResult {
    final int? code;
    final List<UnPackingElement>? result;

    UnPackingResult({
        this.code,
        this.result,
    });

    factory UnPackingResult.fromJson(String str) => UnPackingResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UnPackingResult.fromMap(Map<String, dynamic> json) => UnPackingResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<UnPackingElement>.from(json["result"]!.map((x) => UnPackingElement.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class UnPackingElement {
    final int? idPaquete;
    final String? namePaquete;
    final int? idBatch;
    final int? cantidadProductosEnElPaquete;
    final List<ListItemUnPacking>? listItem;

    UnPackingElement({
        this.idPaquete,
        this.namePaquete,
        this.idBatch,
        this.cantidadProductosEnElPaquete,
        this.listItem,
    });

    factory UnPackingElement.fromJson(String str) => UnPackingElement.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UnPackingElement.fromMap(Map<String, dynamic> json) => UnPackingElement(
        idPaquete: json["id_paquete"],
        namePaquete: json["name_paquete"],
        idBatch: json["id_batch"],
        cantidadProductosEnElPaquete: json["cantidad_productos_en_el_paquete"],
        listItem: json["list_item"] == null ? [] : List<ListItemUnPacking>.from(json["list_item"]!.map((x) => ListItemUnPacking.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id_paquete": idPaquete,
        "name_paquete": namePaquete,
        "id_batch": idBatch,
        "cantidad_productos_en_el_paquete": cantidadProductosEnElPaquete,
        "list_item": listItem == null ? [] : List<dynamic>.from(listItem!.map((x) => x.toMap())),
    };
}

class ListItemUnPacking {
    final int? idMove;
    final int? productId;
    final dynamic? lote;
    final int? locationId;
    final int? cantidadSeparada;
    final String? observacion;
    final int? idOperario;

    ListItemUnPacking({
        this.idMove,
        this.productId,
        this.lote,
        this.locationId,
        this.cantidadSeparada,
        this.observacion,
        this.idOperario,
    });

    factory ListItemUnPacking.fromJson(String str) => ListItemUnPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListItemUnPacking.fromMap(Map<String, dynamic> json) => ListItemUnPacking(
        idMove: json["id_move"],
        productId: json["product_id"],
        lote: json["lote"],
        locationId: json["location_id"],
        cantidadSeparada: json["cantidad_separada"],
        observacion: json["observacion"],
        idOperario: json["id_operario"],
    );

    Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "product_id": productId,
        "lote": lote,
        "location_id": locationId,
        "cantidad_separada": cantidadSeparada,
        "observacion": observacion,
        "id_operario": idOperario,
    };
}
