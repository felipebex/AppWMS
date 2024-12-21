import 'dart:convert';

class NovedadesResponse {
    final List<Novedad>? result;

    NovedadesResponse({
        this.result,
    });

    factory NovedadesResponse.fromJson(String str) => NovedadesResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NovedadesResponse.fromMap(Map<String, dynamic> json) => NovedadesResponse(
        result: json["result"] == null ? [] : List<Novedad>.from(json["result"]!.map((x) => Novedad.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
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
