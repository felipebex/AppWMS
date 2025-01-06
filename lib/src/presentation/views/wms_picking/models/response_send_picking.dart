import 'dart:convert';

class SendPickingResponse {
    final String? jsonrpc;
    final dynamic id;
    final Data? result;

    SendPickingResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory SendPickingResponse.fromJson(String str) => SendPickingResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory SendPickingResponse.fromMap(Map<String, dynamic> json) => SendPickingResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : Data.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class Data {
    final int? code;
    final List<ResultElement>? result;

    Data({
        this.code,
        this.result,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        code: json["code"],
        result: json["result"] == null ? [] : List<ResultElement>.from(json["result"]!.map((x) => ResultElement.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class ResultElement {
    final int? idMove;
    final int? idBatch;
    final int? idProduct;
    final String? complete;

    ResultElement({
        this.idMove,
        this.idBatch,
        this.idProduct,
        this.complete,
    });

    factory ResultElement.fromJson(String str) => ResultElement.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResultElement.fromMap(Map<String, dynamic> json) => ResultElement(
        idMove: json["id_move"],
        idBatch: json["id_batch"],
        idProduct: json["id_product"],
        complete: json["complete"],
    );

    Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "id_batch": idBatch,
        "id_product": idProduct,
        "complete": complete,
    };
}
