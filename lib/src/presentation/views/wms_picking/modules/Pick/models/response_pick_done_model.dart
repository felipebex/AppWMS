import 'dart:convert';

import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/models/response_pick_model.dart';

class ResponsePickDone {
    final String? jsonrpc;
    final dynamic id;
    final ResponsePickDoneResult? result;

    ResponsePickDone({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponsePickDone.fromJson(String str) => ResponsePickDone.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponsePickDone.fromMap(Map<String, dynamic> json) => ResponsePickDone(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResponsePickDoneResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResponsePickDoneResult {
    final int? code;
    final List<ResultPick>? result;
    final List<int>? allowedWarehouses;

    ResponsePickDoneResult({
        this.code,
        this.result,
        this.allowedWarehouses,
    });

    factory ResponsePickDoneResult.fromJson(String str) => ResponsePickDoneResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponsePickDoneResult.fromMap(Map<String, dynamic> json) => ResponsePickDoneResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<ResultPick>.from(json["result"]!.map((x) => ResultPick.fromMap(x))),
        allowedWarehouses: json["allowed_warehouses"] == null ? [] : List<int>.from(json["allowed_warehouses"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
        "allowed_warehouses": allowedWarehouses == null ? [] : List<dynamic>.from(allowedWarehouses!.map((x) => x)),
    };
}
