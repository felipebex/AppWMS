// To parse this JSON data, do
//
//     final responseSendProduct = responseSendProductFromMap(jsonString);

import 'dart:convert';

ResponseSendProduct responseSendProductFromMap(String str) => ResponseSendProduct.fromMap(json.decode(str));

String responseSendProductToMap(ResponseSendProduct data) => json.encode(data.toMap());

class ResponseSendProduct {
    String? jsonrpc;
    dynamic id;
    ResultSend? result;

    ResponseSendProduct({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponseSendProduct.fromMap(Map<String, dynamic> json) => ResponseSendProduct(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResultSend.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResultSend {
    String? status;
    int? data;
    String? message;

    ResultSend({
        this.status,
        this.data,
        this.message,
    });

    factory ResultSend.fromMap(Map<String, dynamic> json) => ResultSend(
        status: json["status"],
        data: json["data"],
        message: json["message"],
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "data": data,
        "message": message,
    };
}
