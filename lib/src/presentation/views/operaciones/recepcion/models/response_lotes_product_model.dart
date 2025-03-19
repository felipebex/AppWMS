// To parse this JSON data, do
//
//     final responseLotesProduct = responseLotesProductFromMap(jsonString);

import 'dart:convert';



class ResponseLotesProduct {
    String? jsonrpc;
    dynamic id;
    ResponseLotesProductResult? result;

    ResponseLotesProduct({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponseLotesProduct.fromMap(Map<String, dynamic> json) => ResponseLotesProduct(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResponseLotesProductResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResponseLotesProductResult {
    int? code;
    List<LotesProduct>? result;

    ResponseLotesProductResult({
        this.code,
        this.result,
    });

    factory ResponseLotesProductResult.fromMap(Map<String, dynamic> json) => ResponseLotesProductResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<LotesProduct>.from(json["result"]!.map((x) => LotesProduct.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class LotesProduct {
    int? id;
    String? name;
    dynamic? quantity;
    dynamic? expirationDate;
    String? alertDate;
    String? useDate;
    int? productId;
    String? productName;

    LotesProduct({
        this.id,
        this.name,
        this.quantity,
        this.expirationDate,
        this.alertDate,
        this.useDate,
        this.productId,
        this.productName,
    });

    factory LotesProduct.fromMap(Map<String, dynamic> json) => LotesProduct(
        id: json["id"],
        name: json["name"],
        quantity: json["quantity"],
        expirationDate: json["expiration_date"],
        alertDate: json["alert_date"],
        useDate: json["use_date"],
        productId: json["product_id"],
        productName: json["product_name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "quantity": quantity,
        "expiration_date": expirationDate,
        "alert_date": alertDate,
        "use_date": useDate,
        "product_id": productId,
        "product_name": productName,
    };
}
