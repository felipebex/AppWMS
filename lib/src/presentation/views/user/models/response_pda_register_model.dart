import 'dart:convert';

class ResponsePdaRegister {
    final String? jsonrpc;
    final dynamic id;
    final Result? result;

    ResponsePdaRegister({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ResponsePdaRegister.fromJson(String str) => ResponsePdaRegister.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResponsePdaRegister.fromMap(Map<String, dynamic> json) => ResponsePdaRegister(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : Result.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class Result {
    final int? code;
    final String? msg;
    final DataPDA? data;

    Result({
        this.code,
        this.msg,
        this.data,
    });

    factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Result.fromMap(Map<String, dynamic> json) => Result(
        code: json["code"],
        msg: json["msg"],
        data: json["data"] == null ? null : DataPDA.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "data": data?.toMap(),
    };
}

class DataPDA {
    final String? deviceId;
    final String? deviceName;
    final String? isAuthorized;
    final bool? isActive;
    final int? totalConnections;
    final int? monthlyConnections;

    DataPDA({
        this.deviceId,
        this.deviceName,
        this.isAuthorized,
        this.isActive,
        this.totalConnections,
        this.monthlyConnections,
    });

    factory DataPDA.fromJson(String str) => DataPDA.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DataPDA.fromMap(Map<String, dynamic> json) => DataPDA(
        deviceId: json["device_id"],
        deviceName: json["device_name"],
        isAuthorized: json["is_authorized"],
        isActive: json["is_active"],
        totalConnections: json["total_connections"],
        monthlyConnections: json["monthly_connections"],
    );

    Map<String, dynamic> toMap() => {
        "device_id": deviceId,
        "device_name": deviceName,
        "is_authorized": isAuthorized,
        "is_active": isActive,
        "total_connections": totalConnections,
        "monthly_connections": monthlyConnections,
    };
}
