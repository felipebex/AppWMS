import 'dart:convert';

class OcuparMuelle {
    final String? jsonrpc;
    final dynamic id;
    final Result? result;

    OcuparMuelle({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory OcuparMuelle.fromJson(String str) => OcuparMuelle.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory OcuparMuelle.fromMap(Map<String, dynamic> json) => OcuparMuelle(
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

    Result({
        this.code,
        this.msg,
    });

    factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Result.fromMap(Map<String, dynamic> json) => Result(
        code: json["code"],
        msg: json["msg"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
    };
}
