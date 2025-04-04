// To parse this JSON data, do
//
//     final configurations = configurationsFromMap(jsonString);

import 'dart:convert';

Configurations configurationsFromMap(String str) =>
    Configurations.fromMap(json.decode(str));

String configurationsToMap(Configurations data) => json.encode(data.toMap());

class Configurations {
  String? jsonrpc;
  dynamic id;
  ConfigurationsResult? result;

  Configurations({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory Configurations.fromMap(Map<String, dynamic> json) => Configurations(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null
            ? null
            : ConfigurationsResult.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class ConfigurationsResult {
  int? code;
  DataConfig? result;

  ConfigurationsResult({
    this.code,
    this.result,
  });

  factory ConfigurationsResult.fromMap(Map<String, dynamic> json) =>
      ConfigurationsResult(
        code: json["code"],
        result:
            json["result"] == null ? null : DataConfig.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "result": result?.toMap(),
      };
}

class DataConfig {
  String? name;
  int? id;
  String? lastName;
  String? email;
  String? rol;
  String? muelleOption;
  List<AllowedWarehouse>? allowedWarehouses;
  bool? locationPickingManual;
  bool? manualProductSelection;
  bool? manualQuantity;
  bool? manualSpringSelection;
  bool? showDetallesPicking;
  bool? showNextLocationsInDetails;
  bool? locationPackManual;
  bool? showDetallesPack;
  bool? showNextLocationsInDetailsPack;
  bool? manualProductSelectionPack;
  bool? manualQuantityPack;
  bool? manualSpringSelectionPack;
  bool? scanProduct;
  bool? allowMoveExcess;
  bool? hideExpectedQty;
  bool? manualProductReading;
  bool? manualSourceLocation;
  bool? showOwnerField;
  bool? manualProductSelectionTransfer;
  bool? manualSourceLocationTransfer;
  bool? manualDestLocationTransfer;
  bool? manualQuantityTransfer;
  bool? countQuantityInventory;

  DataConfig({
    this.name,
    this.id,
    this.lastName,
    this.email,
    this.rol,
    this.muelleOption,
    this.allowedWarehouses,
    this.locationPickingManual,
    this.manualProductSelection,
    this.manualQuantity,
    this.manualSpringSelection,
    this.showDetallesPicking,
    this.showNextLocationsInDetails,
    this.locationPackManual,
    this.showDetallesPack,
    this.showNextLocationsInDetailsPack,
    this.manualProductSelectionPack,
    this.manualQuantityPack,
    this.manualSpringSelectionPack,
    this.scanProduct,
    this.allowMoveExcess,
    this.hideExpectedQty,
    this.manualProductReading,
    this.manualSourceLocation,
    this.showOwnerField,
    this.manualProductSelectionTransfer,
    this.manualSourceLocationTransfer,
    this.manualDestLocationTransfer,
    this.manualQuantityTransfer,
    this.countQuantityInventory,
  });

  factory DataConfig.fromMap(Map<String, dynamic> json) => DataConfig(
        name: json["name"],
        id: json["id"],
        lastName: json["last_name"],
        email: json["email"],
        rol: json["rol"],
        muelleOption: json["muelle_option"],
        allowedWarehouses: json["allowed_warehouses"] == null
            ? []
            : List<AllowedWarehouse>.from(json["allowed_warehouses"]!
                .map((x) => AllowedWarehouse.fromMap(x))),
        locationPickingManual: json["location_picking_manual"],
        manualProductSelection: json["manual_product_selection"],
        manualQuantity: json["manual_quantity"],
        manualSpringSelection: json["manual_spring_selection"],
        showDetallesPicking: json["show_detalles_picking"],
        showNextLocationsInDetails: json["show_next_locations_in_details"],
        locationPackManual: json["location_pack_manual"],
        showDetallesPack: json["show_detalles_pack"],
        showNextLocationsInDetailsPack:
            json["show_next_locations_in_details_pack"],
        manualProductSelectionPack: json["manual_product_selection_pack"],
        manualQuantityPack: json["manual_quantity_pack"],
        manualSpringSelectionPack: json["manual_spring_selection_pack"],
        scanProduct: json["scan_product"],
        allowMoveExcess: json["allow_move_excess"],
        hideExpectedQty: json["hide_expected_qty"],
        manualProductReading: json["manual_product_reading"],
        manualSourceLocation: json["manual_source_location"],
        showOwnerField: json["show_owner_field"],
        manualProductSelectionTransfer:
            json["manual_product_selection_transfer"],
        manualSourceLocationTransfer: json["manual_source_location_transfer"],
        manualDestLocationTransfer: json["manual_dest_location_transfer"],
        manualQuantityTransfer: json["manual_quantity_transfer"],
        countQuantityInventory: json["count_quantity_inventory"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "last_name": lastName,
        "email": email,
        "rol": rol,
        "muelle_option": muelleOption,
        "allowed_warehouses": allowedWarehouses == null
            ? []
            : List<dynamic>.from(allowedWarehouses!.map((x) => x.toMap())),
        "location_picking_manual": locationPickingManual,
        "manual_product_selection": manualProductSelection,
        "manual_quantity": manualQuantity,
        "manual_spring_selection": manualSpringSelection,
        "show_detalles_picking": showDetallesPicking,
        "show_next_locations_in_details": showNextLocationsInDetails,
        "location_pack_manual": locationPackManual,
        "show_detalles_pack": showDetallesPack,
        "show_next_locations_in_details_pack": showNextLocationsInDetailsPack,
        "manual_product_selection_pack": manualProductSelectionPack,
        "manual_quantity_pack": manualQuantityPack,
        "manual_spring_selection_pack": manualSpringSelectionPack,
        "scan_product": scanProduct,
        "allow_move_excess": allowMoveExcess,
        "hide_expected_qty": hideExpectedQty,
        "manual_product_reading": manualProductReading,
        "manual_source_location": manualSourceLocation,
        "show_owner_field": showOwnerField,
        "manual_product_selection_transfer": manualProductSelectionTransfer,
        "manual_source_location_transfer": manualSourceLocationTransfer,
        "manual_dest_location_transfer": manualDestLocationTransfer,
        "manual_quantity_transfer": manualQuantityTransfer,
        "count_quantity_inventory": countQuantityInventory,
      };
}




class AllowedWarehouse {
    int? id;
    String? name;

    AllowedWarehouse({
        this.id,
        this.name,
    });

    factory AllowedWarehouse.fromMap(Map<String, dynamic> json) => AllowedWarehouse(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
    };
}
