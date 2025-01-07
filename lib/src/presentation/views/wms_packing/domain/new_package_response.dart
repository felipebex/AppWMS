import 'dart:convert';

class NewPackageResponse {
    final String? jsonrpc;
    final dynamic id;
    final DataPackage? result;

    NewPackageResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory NewPackageResponse.fromJson(String str) => NewPackageResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NewPackageResponse.fromMap(Map<String, dynamic> json) => NewPackageResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : DataPackage.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class DataPackage {
    final int? code;
    final String? msg;
    final NewPackage? packaging;

    DataPackage({
        this.code,
        this.msg,
        this.packaging,
    });

    factory DataPackage.fromJson(String str) => DataPackage.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DataPackage.fromMap(Map<String, dynamic> json) => DataPackage(
        code: json["code"],
        msg: json["msg"],
        packaging: json["packaging"] == null ? null : NewPackage.fromMap(json["packaging"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "packaging": packaging?.toMap(),
    };
}

class NewPackage {
    final int? id;
    final String? name;
    final DateTime? createDate;
    final DateTime? writeDate;

    NewPackage({
        this.id,
        this.name,
        this.createDate,
        this.writeDate,
    });

    factory NewPackage.fromJson(String str) => NewPackage.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NewPackage.fromMap(Map<String, dynamic> json) => NewPackage(
        id: json["id"],
        name: json["name"],
        createDate: json["create_date"] == null ? null : DateTime.parse(json["create_date"]),
        writeDate: json["write_date"] == null ? null : DateTime.parse(json["write_date"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "create_date": createDate?.toIso8601String(),
        "write_date": writeDate?.toIso8601String(),
    };
}
