import 'dart:convert';

class Configurations {
    final Data? data;

    Configurations({
        this.data,
    });

    factory Configurations.fromJson(String str) => Configurations.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Configurations.fromMap(Map<String, dynamic> json) => Configurations(
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
    final bool? locationPickingManual;
    final bool? manualProductSelection;
    final bool? manualQuantity;
    final bool? manualSpringSelection;
    final bool? showDetallesPicking;
    final bool? showNextLocationsInDetails;

    Result({
        this.name,
        this.lastName,
        this.email,
        this.rol,
        this.locationPickingManual,
        this.manualProductSelection,
        this.manualQuantity,
        this.manualSpringSelection,
        this.showDetallesPicking,
        this.showNextLocationsInDetails,
    });

    factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Result.fromMap(Map<String, dynamic> json) => Result(
        name: json["name"],
        lastName: json["last_name"],
        email: json["email"],
        rol: json["rol"],
        locationPickingManual: json["location_picking_manual"],
        manualProductSelection: json["manual_product_selection"],
        manualQuantity: json["manual_quantity"],
        manualSpringSelection: json["manual_spring_selection"],
        showDetallesPicking: json["show_detalles_picking"],
        showNextLocationsInDetails: json["show_next_locations_in_details"],
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "last_name": lastName,
        "email": email,
        "rol": rol,
        "location_picking_manual": locationPickingManual,
        "manual_product_selection": manualProductSelection,
        "manual_quantity": manualQuantity,
        "manual_spring_selection": manualSpringSelection,
        "show_detalles_picking": showDetallesPicking,
        "show_next_locations_in_details": showNextLocationsInDetails,
    };
}
