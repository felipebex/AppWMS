// To parse this JSON data, do
//
//     final responsePick = responsePickFromMap(jsonString);

import 'dart:convert';

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

ResponsePick responsePickFromMap(String str) =>
    ResponsePick.fromMap(json.decode(str));

String responsePickToMap(ResponsePick data) => json.encode(data.toMap());

class ResponsePick {
  String? jsonrpc;
  dynamic id;
  ResponsePickResult? result;

  ResponsePick({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory ResponsePick.fromMap(Map<String, dynamic> json) => ResponsePick(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null
            ? null
            : ResponsePickResult.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class ResponsePickResult {
  int? code;
  List<ResultPick>? result;

  ResponsePickResult({
    this.code,
    this.result,
  });

  factory ResponsePickResult.fromMap(Map<String, dynamic> json) =>
      ResponsePickResult(
        code: json["code"],
        result: json["result"] == null
            ? []
            : List<ResultPick>.from(
                json["result"]!.map((x) => ResultPick.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class ResultPick {
  int? id;
  String? name;
  String? fechaCreacion;
  int? locationId;
  String? locationName;
  String? locationBarcode;
  int? locationDestId;
  String? locationDestName;
  String? locationDestBarcode;
  String? proveedor;
  String? numeroTransferencia;
  int? pesoTotal;
  dynamic numeroLineas;
  dynamic numeroItems;
  String? state;
  String? origin;
  String? priority;
  int? warehouseId;
  String? warehouseName;
  int? responsableId;
  String? responsable;
  String? pickingType;
  String? startTimeTransfer;
  String? endTimeTransfer;
  int? backorderId;
  String? backorderName;
  dynamic showCheckAvailability;

  String? typePick;

  //valores para el pick
  dynamic isSeparate;
  dynamic isSelected;
  String? zonaEntrega;
  String? muelle;
  final int? indexList;
  final String? barcodeMuelle;
  final dynamic muelleId;
  final String? isSendOdoo;
  final String? isSendOdooDate;
  final String? observation;
  final dynamic orderBy;
  final dynamic orderPicking;

  List<ProductsBatch>? lineasTransferencia;

  List<ProductsBatch>? lineasTransferenciaEnviadas;

  ResultPick({
    this.id,
    this.name,
    this.fechaCreacion,
    this.locationId,
    this.locationName,
    this.locationBarcode,
    this.locationDestId,
    this.locationDestName,
    this.locationDestBarcode,
    this.proveedor,
    this.numeroTransferencia,
    this.pesoTotal,
    this.numeroLineas,
    this.numeroItems,
    this.state,
    this.origin,
    this.priority,
    this.warehouseId,
    this.warehouseName,
    this.responsableId,
    this.responsable,
    this.pickingType,
    this.startTimeTransfer,
    this.endTimeTransfer,
    this.backorderId,
    this.backorderName,
    this.showCheckAvailability,
    this.lineasTransferencia,
    this.lineasTransferenciaEnviadas,
    this.isSeparate,
    this.isSelected,
    this.zonaEntrega,
    this.muelle,
    this.barcodeMuelle,
    this.muelleId,
    this.indexList,
    this.isSendOdoo,
    this.isSendOdooDate,
    this.observation,
    this.orderBy,
    this.orderPicking,
    this.typePick,

  });

  factory ResultPick.fromMap(Map<String, dynamic> json) => ResultPick(
        id: json["id"],
        name: json["name"],
        fechaCreacion: json["fecha_creacion"],
        locationId: json["location_id"],
        locationName: json["location_name"],
        locationBarcode: json["location_barcode"],
        locationDestId: json["location_dest_id"],
        locationDestName: json["location_dest_name"],
        locationDestBarcode: json["location_dest_barcode"],
        proveedor: json["proveedor"],
        numeroTransferencia: json["numero_transferencia"],
        pesoTotal: json["peso_total"],
        numeroLineas: json["numero_lineas"],
        numeroItems: json["numero_items"],
        state: json["state"],
        origin: json["origin"],
        priority: json["priority"],
        warehouseId: json["warehouse_id"],
        warehouseName: json["warehouse_name"],
        responsableId: json["responsable_id"],
        responsable: json["responsable"],
        pickingType: json["picking_type"],
        startTimeTransfer: json["start_time_transfer"],
        endTimeTransfer: json["end_time_transfer"],
        backorderId: json["backorder_id"],
        backorderName: json["backorder_name"],
        showCheckAvailability: json["show_check_availability"],
        lineasTransferencia: json["lineas_transferencia"] == null
            ? []
            : List<ProductsBatch>.from(json["lineas_transferencia"]!
                .map((x) => ProductsBatch.fromMap(x))),
        lineasTransferenciaEnviadas:
            json["lineas_transferencia_enviadas"] == null
                ? []
                : List<ProductsBatch>.from(
                    json["lineas_transferencia_enviadas"]!
                        .map((x) => ProductsBatch.fromMap(x))),
        isSeparate: json["is_separate"],
        isSelected: json["is_selected"],
        zonaEntrega: json["zona_entrega"],
        muelle: json["muelle"],
        barcodeMuelle: json["barcode_muelle"],
        muelleId: json["muelle_id"],
        indexList: json["index_list"],
        isSendOdoo: json["is_send_odoo"],
        isSendOdooDate: json["is_send_odoo_date"],
        observation: json["observation"],
        orderBy: json["order_by"],
        orderPicking: json["order_picking"],
        typePick: json["type_pick"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "fecha_creacion": fechaCreacion,
        "location_id": locationId,
        "location_name": locationName,
        "location_barcode": locationBarcode,
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestName,
        "location_dest_barcode": locationDestBarcode,
        "proveedor": proveedor,
        "numero_transferencia": numeroTransferencia,
        "peso_total": pesoTotal,
        "numero_lineas": numeroLineas,
        "numero_items": numeroItems,
        "state": state,
        "origin": origin,
        "priority": priority,
        "warehouse_id": warehouseId,
        "warehouse_name": warehouseName,
        "responsable_id": responsableId,
        "responsable": responsable,
        "picking_type": pickingType,
        "start_time_transfer": startTimeTransfer,
        "end_time_transfer": endTimeTransfer,
        "backorder_id": backorderId,
        "backorder_name": backorderName,
        "show_check_availability": showCheckAvailability,
        "lineas_transferencia": lineasTransferencia == null
            ? []
            : List<dynamic>.from(lineasTransferencia!.map((x) => x.toMap())),
        "lineas_transferencia_enviadas": lineasTransferenciaEnviadas == null
            ? []
            : List<dynamic>.from(
                lineasTransferenciaEnviadas!.map((x) => x.toMap())),
        "is_separate": isSeparate,
        "is_selected": isSelected,
        "zona_entrega": zonaEntrega,
        "muelle": muelle,
        "barcode_muelle": barcodeMuelle,
        "muelle_id": muelleId,
        "index_list": indexList,
        "is_send_odoo": isSendOdoo,
        "is_send_odoo_date": isSendOdooDate,
        "observation": observation,
        "order_by": orderBy,
        "order_picking": orderPicking,
        "type_pick": typePick,
      };
}
