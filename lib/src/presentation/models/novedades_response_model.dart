import 'dart:convert';

class NovedadesResponse {
    final String? jsonrpc;
    final dynamic id;
    final NovedadesResponseResult? result;

    NovedadesResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory NovedadesResponse.fromJson(String str) => NovedadesResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NovedadesResponse.fromMap(Map<String, dynamic> json) => NovedadesResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : NovedadesResponseResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class NovedadesResponseResult {
    final int? code;
    final List<Novedad>? result;

    NovedadesResponseResult({
        this.code,
        this.result,
    });

    factory NovedadesResponseResult.fromJson(String str) => NovedadesResponseResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NovedadesResponseResult.fromMap(Map<String, dynamic> json) => NovedadesResponseResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<Novedad>.from(json["result"]!.map((x) => Novedad.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class Novedad {
    final int? id;
    final String? name;
    final String? code;

    Novedad({
        this.id,
        this.name,
        this.code,
    });

    factory Novedad.fromJson(String str) => Novedad.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Novedad.fromMap(Map<String, dynamic> json) => Novedad(
        id: json["id"],
        name: json["name"],
        code: json["code"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "code": code,
    };
}
