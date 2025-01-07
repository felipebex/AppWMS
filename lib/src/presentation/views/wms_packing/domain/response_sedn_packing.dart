import 'dart:convert';

class ResponseSendPacking {
    final String? jsonrpc;
    final dynamic id;
    final ResponseSendPackingResult? result;

    ResponseSendPacking({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponseSendPacking.fromJson(String str) => ResponseSendPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponseSendPacking.fromMap(Map<String, dynamic> json) => ResponseSendPacking(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResponseSendPackingResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResponseSendPackingResult {
    final int? code;
    final List<ResultElement>? result;

    ResponseSendPackingResult({
        this.code,
        this.result,
    });

    factory ResponseSendPackingResult.fromJson(String str) => ResponseSendPackingResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponseSendPackingResult.fromMap(Map<String, dynamic> json) => ResponseSendPackingResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<ResultElement>.from(json["result"]!.map((x) => ResultElement.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class ResultElement {
    final int? idPaquete;
    final String? namePaquete;
    final int? idBatch;
    final int? cantidadProductosEnElPaquete;
    final bool? isSticker;
    final bool? isCertificate;
    final dynamic? peso;
    final List<ListItem>? listItem;

    ResultElement({
        this.idPaquete,
        this.namePaquete,
        this.idBatch,
        this.cantidadProductosEnElPaquete,
        this.isSticker,
        this.isCertificate,
        this.peso,
        this.listItem,
    });

    factory ResultElement.fromJson(String str) => ResultElement.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResultElement.fromMap(Map<String, dynamic> json) => ResultElement(
        idPaquete: json["id_paquete"],
        namePaquete: json["name_paquete"],
        idBatch: json["id_batch"],
        cantidadProductosEnElPaquete: json["cantidad_productos_en_el_paquete"],
        isSticker: json["is_sticker"],
        isCertificate: json["is_certificate"],
        peso: json["peso"],
        listItem: json["list_item"] == null ? [] : List<ListItem>.from(json["list_item"]!.map((x) => ListItem.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id_paquete": idPaquete,
        "name_paquete": namePaquete,
        "id_batch": idBatch,
        "cantidad_productos_en_el_paquete": cantidadProductosEnElPaquete,
        "is_sticker": isSticker,
        "is_certificate": isCertificate,
        "peso": peso,
        "list_item": listItem == null ? [] : List<dynamic>.from(listItem!.map((x) => x.toMap())),
    };
}

class ListItem {
    final int? idMove;
    final int? productId;
    final String? lote;
    final int? locationId;
    final int? cantidadSeparada;
    final String? observacion;
    final String? unidadMedida;
    final int? idOperario;

    ListItem({
        this.idMove,
        this.productId,
        this.lote,
        this.locationId,
        this.cantidadSeparada,
        this.observacion,
        this.unidadMedida,
        this.idOperario,
    });

    factory ListItem.fromJson(String str) => ListItem.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListItem.fromMap(Map<String, dynamic> json) => ListItem(
        idMove: json["id_move"],
        productId: json["product_id"],
        lote: json["lote"],
        locationId: json["location_id"],
        cantidadSeparada: json["cantidad_separada"],
        observacion: json["observacion"],
        unidadMedida: json["unidad_medida"],
        idOperario: json["id_operario"],
    );

    Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "product_id": productId,
        "lote": lote,
        "location_id": locationId,
        "cantidad_separada": cantidadSeparada,
        "observacion": observacion,
        "unidad_medida": unidadMedida,
        "id_operario": idOperario,
    };
}
