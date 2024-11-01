import 'dart:convert';

class UserModelResponse {
    final Data? data;

    UserModelResponse({
        this.data,
    });

    factory UserModelResponse.fromJson(String str) => UserModelResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserModelResponse.fromMap(Map<String, dynamic> json) => UserModelResponse(
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
    };
}

class Data {
    final int? code;
    final Result? result;

    Data({
        this.code,
        this.result,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        code: json["code"],
        result: json["result"] == null ? null : Result.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result?.toMap(),
    };
}

class Result {
    final String? name;
    final String? lastName;
    final String? email;
    final String? rol;
    final List<Location>? locations;

    Result({
        this.name,
        this.lastName,
        this.email,
        this.rol,
        this.locations,
    });

    factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Result.fromMap(Map<String, dynamic> json) => Result(
        name: json["name"],
        lastName: json["last_name"],
        email: json["email"],
        rol: json["rol"],
        locations: json["locations"] == null ? [] : List<Location>.from(json["locations"]!.map((x) => Location.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "last_name": lastName,
        "email": email,
        "rol": rol,
        "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toMap())),
    };
}

class Location {
    final int? locationId;
    final String? name;

    Location({
        this.locationId,
        this.name,
    });

    factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Location.fromMap(Map<String, dynamic> json) => Location(
        locationId: json["location_id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "location_id": locationId,
        "name": name,
    };
}
