// To parse this JSON data, do
//
//     final responseNewLote = responseNewLoteFromMap(jsonString);

import 'dart:convert';

import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';

ResponseNewLote responseNewLoteFromMap(String str) => ResponseNewLote.fromMap(json.decode(str));

String responseNewLoteToMap(ResponseNewLote data) => json.encode(data.toMap());

class ResponseNewLote {
    String? jsonrpc;
    dynamic id;
    ResponseNewLoteResult? result;

    ResponseNewLote({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponseNewLote.fromMap(Map<String, dynamic> json) => ResponseNewLote(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResponseNewLoteResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResponseNewLoteResult {
    int? code;
    LotesProduct? result;

    ResponseNewLoteResult({
        this.code,
        this.result,
    });

    factory ResponseNewLoteResult.fromMap(Map<String, dynamic> json) => ResponseNewLoteResult(
        code: json["code"],
        result: json["result"] == null ? null : LotesProduct.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result?.toMap(),
    };
}
