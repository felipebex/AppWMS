
import 'dart:convert';

class MuellesResponse {
    final List<Muelles>? result;

    MuellesResponse({
        this.result,
    });

    factory MuellesResponse.fromJson(String str) => MuellesResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MuellesResponse.fromMap(Map<String, dynamic> json) => MuellesResponse(
        result: json["result"] == null ? [] : List<Muelles>.from(json["result"]!.map((x) => Muelles.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
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
