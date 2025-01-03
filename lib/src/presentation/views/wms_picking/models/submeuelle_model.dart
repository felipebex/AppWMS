import 'dart:convert';

class MuellesResponse {
    final String? jsonrpc;
    final dynamic id;
    final MuellesResponseResult? result;

    MuellesResponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory MuellesResponse.fromJson(String str) => MuellesResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MuellesResponse.fromMap(Map<String, dynamic> json) => MuellesResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : MuellesResponseResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class MuellesResponseResult {
    final int? code;
    final List<Muelles>? result;

    MuellesResponseResult({
        this.code,
        this.result,
    });

    factory MuellesResponseResult.fromJson(String str) => MuellesResponseResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MuellesResponseResult.fromMap(Map<String, dynamic> json) => MuellesResponseResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<Muelles>.from(json["result"]!.map((x) => Muelles.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class Muelles {
    final int? id;
    final String? name;
    final String? completeName;
    final int? locationId;
    final String? barcode;

    Muelles({
        this.id,
        this.name,
        this.completeName,
        this.locationId,
        this.barcode,
    });

    factory Muelles.fromJson(String str) => Muelles.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Muelles.fromMap(Map<String, dynamic> json) => Muelles(
        id: json["id"],
        name: json["name"],
        completeName: json["complete_name"],
        locationId: json["location_id"],
        barcode: json["barcode"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "complete_name": completeName,
        "location_id": locationId,
        "barcode": barcode,
    };
}
