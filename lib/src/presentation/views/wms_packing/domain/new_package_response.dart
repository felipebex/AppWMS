import 'dart:convert';

class NewPackageResponse {
    final DataPackage? data;

    NewPackageResponse({
        this.data,
    });

    factory NewPackageResponse.fromJson(String str) => NewPackageResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NewPackageResponse.fromMap(Map<String, dynamic> json) => NewPackageResponse(
        data: json["data"] == null ? null : DataPackage.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
    };
}

class DataPackage {
    final int? code;
    final String? msg;
    final List<NewPackage>? packaging;

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
        packaging: json["packaging"] == null ? [] : List<NewPackage>.from(json["packaging"]!.map((x) => NewPackage.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "packaging": packaging == null ? [] : List<dynamic>.from(packaging!.map((x) => x.toMap())),
    };
}

class NewPackage {
    final int? id;
    final String? name;

    NewPackage({
        this.id,
        this.name,
    });

    factory NewPackage.fromJson(String str) => NewPackage.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NewPackage.fromMap(Map<String, dynamic> json) => NewPackage(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
    };
}
