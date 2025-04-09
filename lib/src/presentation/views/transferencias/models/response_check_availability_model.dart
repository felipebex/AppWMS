// To parse this JSON data, do
//
//     final checkAvailabilityResponse = checkAvailabilityResponseFromMap(jsonString);

import 'dart:convert';

import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';

CheckAvailabilityResponse checkAvailabilityResponseFromMap(String str) => CheckAvailabilityResponse.fromMap(json.decode(str));

String checkAvailabilityResponseToMap(CheckAvailabilityResponse data) => json.encode(data.toMap());

class CheckAvailabilityResponse {
    String? jsonrpc;
    dynamic id;
    CheckAvailabilityResponseResult? result;

    CheckAvailabilityResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory CheckAvailabilityResponse.fromMap(Map<String, dynamic> json) => CheckAvailabilityResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : CheckAvailabilityResponseResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class CheckAvailabilityResponseResult {
    int? code;
    String? msg;
    ResultTransFerencias? result;

    CheckAvailabilityResponseResult({
        this.code,
        this.msg,
        this.result,
    });

    factory CheckAvailabilityResponseResult.fromMap(Map<String, dynamic> json) => CheckAvailabilityResponseResult(
        code: json["code"],
        msg: json["msg"],
        result: json["result"] == null ? null : ResultTransFerencias.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "result": result?.toMap(),
    };
}
