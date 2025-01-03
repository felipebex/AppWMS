import 'dart:convert';

class Configurations {
    final String? jsonrpc;
    final dynamic id;
    final ConfigurationsResult? result;

    Configurations({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory Configurations.fromJson(String str) => Configurations.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Configurations.fromMap(Map<String, dynamic> json) => Configurations(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ConfigurationsResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ConfigurationsResult {
    final int? code;
    final DataConfig? result;

    ConfigurationsResult({
        this.code,
        this.result,
    });

    factory ConfigurationsResult.fromJson(String str) => ConfigurationsResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ConfigurationsResult.fromMap(Map<String, dynamic> json) => ConfigurationsResult(
        code: json["code"],
        result: json["result"] == null ? null : DataConfig.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result?.toMap(),
    };
}

class DataConfig {
    final String? name;
    final int? id;
    final String? lastName;
    final String? email;
    final String? rol;
    final String? muelleOption;
    final bool? locationPickingManual;
    final bool? manualProductSelection;
    final bool? manualQuantity;
    final bool? manualSpringSelection;
    final bool? showDetallesPicking;
    final bool? showNextLocationsInDetails;

    DataConfig({
        this.name,
        this.id,
        this.lastName,
        this.email,
        this.rol,
        this.muelleOption,
        this.locationPickingManual,
        this.manualProductSelection,
        this.manualQuantity,
        this.manualSpringSelection,
        this.showDetallesPicking,
        this.showNextLocationsInDetails,
    });

    factory DataConfig.fromJson(String str) => DataConfig.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DataConfig.fromMap(Map<String, dynamic> json) => DataConfig(
        name: json["name"],
        id: json["id"],
        lastName: json["last_name"],
        email: json["email"],
        rol: json["rol"],
        muelleOption: json["muelle_option"],
        locationPickingManual: json["location_picking_manual"],
        manualProductSelection: json["manual_product_selection"],
        manualQuantity: json["manual_quantity"],
        manualSpringSelection: json["manual_spring_selection"],
        showDetallesPicking: json["show_detalles_picking"],
        showNextLocationsInDetails: json["show_next_locations_in_details"],
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "last_name": lastName,
        "email": email,
        "rol": rol,
        "muelle_option": muelleOption,
        "location_picking_manual": locationPickingManual,
        "manual_product_selection": manualProductSelection,
        "manual_quantity": manualQuantity,
        "manual_spring_selection": manualSpringSelection,
        "show_detalles_picking": showDetallesPicking,
        "show_next_locations_in_details": showNextLocationsInDetails,
    };
}
