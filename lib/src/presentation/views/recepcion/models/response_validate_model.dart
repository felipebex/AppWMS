// To parse this JSON data, do
//
//     final responseValidate = responseValidateFromMap(jsonString);

import 'dart:convert';

ResponseValidate responseValidateFromMap(String str) => ResponseValidate.fromMap(json.decode(str));

String responseValidateToMap(ResponseValidate data) => json.encode(data.toMap());

class ResponseValidate {
    String? jsonrpc;
    ResultValidate? result;

    ResponseValidate({
        this.jsonrpc,
        this.result,
    });

    factory ResponseValidate.fromMap(Map<String, dynamic> json) => ResponseValidate(
        jsonrpc: json["jsonrpc"],
        result: json["result"] == null ? null : ResultValidate.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "result": result?.toMap(),
    };
}

class ResultValidate {
    int? code;
    String? msg;

    ResultValidate({
        this.code,
        this.msg,
    });

    factory ResultValidate.fromMap(Map<String, dynamic> json) => ResultValidate(
        code: json["code"],
        msg: json["msg"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
    };
}
