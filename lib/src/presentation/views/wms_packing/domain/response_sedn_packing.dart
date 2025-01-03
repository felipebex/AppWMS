import 'dart:convert';

class ResponseSendPacking {
    final DataResponsePacking? data;

    ResponseSendPacking({
        this.data,
    });

    factory ResponseSendPacking.fromJson(String str) => ResponseSendPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponseSendPacking.fromMap(Map<String, dynamic> json) => ResponseSendPacking(
        data: json["data"] == null ? null : DataResponsePacking.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
    };
}

class DataResponsePacking {
    final int? code;
    final List<ResultPacking>? result;

    DataResponsePacking({
        this.code,
        this.result,
    });

    factory DataResponsePacking.fromJson(String str) => DataResponsePacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DataResponsePacking.fromMap(Map<String, dynamic> json) => DataResponsePacking(
        code: json["code"],
        result: json["result"] == null ? [] : List<ResultPacking>.from(json["result"]!.map((x) => ResultPacking.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class ResultPacking {
    final int? idPaquete;
    final String? namePaquete;
    final int? idBatch;
    final int? cantidadProductosEnElPaquete;
    final bool? isStickrer;
    final dynamic? peso;
    final List<ListItem>? listItem;

    ResultPacking({
        this.idPaquete,
        this.namePaquete,
        this.idBatch,
        this.cantidadProductosEnElPaquete,
        this.isStickrer,
        this.peso,
        this.listItem,
    });

    factory ResultPacking.fromJson(String str) => ResultPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResultPacking.fromMap(Map<String, dynamic> json) => ResultPacking(
        idPaquete: json["id_paquete"],
        namePaquete: json["name_paquete"],
        idBatch: json["id_batch"],
        cantidadProductosEnElPaquete: json["cantidad_productos_en_el_paquete"],
        isStickrer: json["is_stickrer"],
        peso: json["peso"],
        listItem: json["list_item"] == null ? [] : List<ListItem>.from(json["list_item"]!.map((x) => ListItem.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id_paquete": idPaquete,
        "name_paquete": namePaquete,
        "id_batch": idBatch,
        "cantidad_productos_en_el_paquete": cantidadProductosEnElPaquete,
        "is_stickrer": isStickrer,
        "peso": peso,
        "list_item": listItem == null ? [] : List<dynamic>.from(listItem!.map((x) => x.toMap())),
    };
}

class ListItem {
    final int? idMove;
    final int? productId;
    final String? lote;
    final int? locationId;
    final dynamic? cantidadSeparada;
    final String? unidadMedida;
    final String? observacion;

    ListItem({
        this.idMove,
        this.productId,
        this.lote,
        this.locationId,
        this.cantidadSeparada,
        this.unidadMedida,
        this.observacion,
    });

    factory ListItem.fromJson(String str) => ListItem.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListItem.fromMap(Map<String, dynamic> json) => ListItem(
        idMove: json["id_move"],
        productId: json["product_id"],
        lote: json["lote"],
        locationId: json["location_id"],
        cantidadSeparada: json["cantidad_separada"],
        unidadMedida: json["unidad_medida"],
        observacion: json["observacion"],
    );

    Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "product_id": productId,
        "lote": lote,
        "location_id": locationId,
        "cantidad_separada": cantidadSeparada,
        "unidad_medida": unidadMedida,
        "observacion": observacion,
    };
}
