import 'dart:convert';

class Configurations {
    final DataConfig? data;

    Configurations({
        this.data,
    });

    factory Configurations.fromJson(String str) => Configurations.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Configurations.fromMap(Map<String, dynamic> json) => Configurations(
        data: json["data"] == null ? null : DataConfig.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
    };
}

class DataConfig {
    final int? code;
    final Result? result;

    DataConfig({
        this.code,
        this.result,
    });

    factory DataConfig.fromJson(String str) => DataConfig.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DataConfig.fromMap(Map<String, dynamic> json) => DataConfig(
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
    final int? userId;
    final bool? locationPickingManual;
    final bool? manualProductSelection;
    final bool? manualQuantity;
    final bool? manualSpringSelection;
    final bool? showDetallesPicking;
    final bool? showNextLocationsInDetails;

    Result({
        this.name,
        this.lastName,
        this.userId,
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
        userId: json["user_id"],
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
        "user_id": userId,
        "location_picking_manual": locationPickingManual,
        "manual_product_selection": manualProductSelection,
        "manual_quantity": manualQuantity,
        "manual_spring_selection": manualSpringSelection,
        "show_detalles_picking": showDetallesPicking,
        "show_next_locations_in_details": showNextLocationsInDetails,
    };
}
