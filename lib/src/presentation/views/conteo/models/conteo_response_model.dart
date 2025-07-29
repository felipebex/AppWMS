import 'dart:convert';

class ResponseConteo {
  final String? jsonrpc;
  final dynamic id;
  final ResultConteo? result;

  ResponseConteo({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory ResponseConteo.fromJson(String str) =>
      ResponseConteo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResponseConteo.fromMap(Map<String, dynamic> json) => ResponseConteo(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null
            ? null
            : ResultConteo.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class ResultConteo {
  final int? code;
  final String? msg;
  final List<DatumConteo>? data;

  ResultConteo({
    this.code,
    this.msg,
    this.data,
  });

  factory ResultConteo.fromJson(String str) =>
      ResultConteo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResultConteo.fromMap(Map<String, dynamic> json) => ResultConteo(
        code: json["code"],
        msg: json["msg"],
        data: json["data"] == null
            ? []
            : List<DatumConteo>.from(
                json["data"]!.map((x) => DatumConteo.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class DatumConteo {
  final int? id;
  final String? name;
  final String? state;
  final int? warehouseId;
  final String? warehouseName;
  final int? responsableId;
  final String? responsableName;
  final dynamic? createDate;
  final dynamic? dateCount;
  final dynamic? mostrarCantidad;
  final String? countType;
  final String? numberCount;
  final int? numeroLineas;
  final int? numeroItemsContados;
  final String? filterType;
  final dynamic? enableAllLocations;
  final dynamic? enableAllProducts;

  final dynamic? isDoneItem; 

  final dynamic isSelected;
  final dynamic isStarted;
  final dynamic isFinished;
  final String? startTimeOrden;
  final String? endTimeOrden;

  final List<Allowed>? allowedCategories;
  final List<Allowed>? allowedLocations;
  final List<dynamic>? allowedProducts;



  final List<CountedLine>? countedLines;
  final List<CountedLine>? countedLinesDone;

  DatumConteo({
    this.id,
    this.name,
    this.state,
    this.warehouseId,
    this.warehouseName,
    this.responsableId,
    this.responsableName,
    this.createDate,
    this.dateCount,
    this.mostrarCantidad,
    this.countType,
    this.numberCount,
    this.numeroLineas,
    this.numeroItemsContados,
    this.filterType,
    this.enableAllLocations,
    this.enableAllProducts,
    this.allowedCategories,
    this.allowedLocations,
    this.allowedProducts,
    this.countedLines,
    this.countedLinesDone,
    this.isSelected,
    this.isStarted,
    this.isFinished,
    this.startTimeOrden,
    this.endTimeOrden,
    this.isDoneItem,
  });

  factory DatumConteo.fromJson(String str) =>
      DatumConteo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DatumConteo.fromMap(Map<String, dynamic> json) => DatumConteo(
        id: json["id"],
        name: json["name"],
        state: json["state"],
        warehouseId: json["warehouse_id"],
        warehouseName: json["warehouse_name"],
        responsableId: json["responsable_id"],
        responsableName: json["responsable_name"],
        createDate: json["create_date"] == null
            ? null
            : DateTime.parse(json["create_date"]),
        dateCount: json["date_count"] == null
            ? null
            : DateTime.parse(json["date_count"]),
        mostrarCantidad: json["mostrar_cantidad"],
        countType: json["count_type"],
        numberCount: json["number_count"],
        numeroLineas: json["numero_lineas"],
        numeroItemsContados: json["numero_items_contados"],
        filterType: json["filter_type"],
        enableAllLocations: json["enable_all_locations"],
        enableAllProducts: json["enable_all_products"],
        allowedCategories: json["allowed_categories"] == null
            ? []
            : List<Allowed>.from(
                json["allowed_categories"]!.map((x) => Allowed.fromMap(x))),
        allowedLocations: json["allowed_locations"] == null
            ? []
            : List<Allowed>.from(
                json["allowed_locations"]!.map((x) => Allowed.fromMap(x))),
        allowedProducts: json["allowed_products"] == null
            ? []
            : List<dynamic>.from(json["allowed_products"]!.map((x) => x)),
        countedLines: json["counted_lines"] == null
            ? []
            : List<CountedLine>.from(
                json["counted_lines"]!.map((x) => CountedLine.fromMap(x))),
        countedLinesDone: json["counted_lines_done"] == null
            ? []
            : List<CountedLine>.from(
                json["counted_lines_done"]!.map((x) => CountedLine.fromMap(x))),
        isSelected: json["is_selected"],
        isStarted: json["is_started"],
        isFinished: json["is_finished"],
        startTimeOrden: json["start_time_orden"],
        endTimeOrden: json["end_time_orden"],
        isDoneItem: json["is_done_item"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "state": state,
        "warehouse_id": warehouseId,
        "warehouse_name": warehouseName,
        "responsable_id": responsableId,
        "responsable_name": responsableName,
        "create_date": createDate?.toIso8601String(),
        "date_count":
            "${dateCount!.year.toString().padLeft(4, '0')}-${dateCount!.month.toString().padLeft(2, '0')}-${dateCount!.day.toString().padLeft(2, '0')}",
        "mostrar_cantidad": mostrarCantidad,
        "count_type": countType,
        "number_count": numberCount,
        "numero_lineas": numeroLineas,
        "numero_items_contados": numeroItemsContados,
        "filter_type": filterType,
        "enable_all_locations": enableAllLocations,
        "enable_all_products": enableAllProducts,
        "allowed_categories": allowedCategories == null
            ? []
            : List<dynamic>.from(allowedCategories!.map((x) => x.toMap())),
        "allowed_locations": allowedLocations == null
            ? []
            : List<dynamic>.from(allowedLocations!.map((x) => x.toMap())),
        "allowed_products": allowedProducts == null
            ? []
            : List<dynamic>.from(allowedProducts!.map((x) => x)),
        "counted_lines": countedLines == null
            ? []
            : List<dynamic>.from(countedLines!.map((x) => x.toMap())),
        "counted_lines_done": countedLinesDone == null
            ? []
            : List<dynamic>.from(countedLinesDone!.map((x) => x)),
        "is_selected": isSelected,
        "is_started": isStarted,
        "is_finished": isFinished,
        "start_time_orden": startTimeOrden,
        "end_time_orden": endTimeOrden,
        "is_done_item": isDoneItem,
      };
}

class Allowed {
  final int? id;
  final String? name;
  final int? ordenConteoId;

  Allowed({
    this.id,
    this.name,
    this.ordenConteoId,
  });

  factory Allowed.fromJson(String str) => Allowed.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Allowed.fromMap(Map<String, dynamic> json) => Allowed(
        id: json["id"],
        name: json["name"],
        ordenConteoId: json["orden_conteo_id"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "orden_conteo_id": ordenConteoId,
      };
}

class CountedLine {
  final int? id;
  final int? orderId;
  final int? productId;
  final String? productName;
  final String? productCode;
  final String? productBarcode;
  final String? productTracking;
  final List<dynamic>? otherBarcodes;
  final List<dynamic>? productPacking;
  final int? locationId;
  final String? locationName;
  final String? locationBarcode;
  final dynamic? quantityInventory;
  final dynamic? quantityCounted;
  final dynamic? differenceQty;
  final String? uom;
  final dynamic? weight;
  final dynamic? isDoneItem;
  final String? dateTransaction;
  final String? observation;
  final dynamic? time;
  final int? userOperatorId;
  final String? userOperatorName;
  final int? categoryId;
  final String? categoryName;
  final int? lotId;
  final String? lotName;
  final String? fechaVencimiento;

  CountedLine({
    this.id,
    this.orderId,
    this.productId,
    this.productName,
    this.productCode,
    this.productBarcode,
    this.productTracking,
    this.otherBarcodes,
    this.productPacking,
    this.locationId,
    this.locationName,
    this.locationBarcode,
    this.quantityInventory,
    this.quantityCounted,
    this.differenceQty,
    this.uom,
    this.weight,
    this.isDoneItem,
    this.dateTransaction,
    this.observation,
    this.time,
    this.userOperatorId,
    this.userOperatorName,
    this.categoryId,
    this.categoryName,
    this.lotId,
    this.lotName,
    this.fechaVencimiento,
  });

  factory CountedLine.fromJson(String str) =>
      CountedLine.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CountedLine.fromMap(Map<String, dynamic> json) => CountedLine(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        productCode: json["product_code"],
        productBarcode: json["product_barcode"],
        productTracking: json["product_tracking"],
        otherBarcodes: json["other_barcodes"] == null
            ? []
            : List<dynamic>.from(json["other_barcodes"]!.map((x) => x)),
        productPacking: json["product_packing"] == null
            ? []
            : List<dynamic>.from(json["product_packing"]!.map((x) => x)),
        locationId: json["location_id"],
        locationName: json["location_name"],
        locationBarcode: json["location_barcode"],
        quantityInventory: json["quantity_inventory"],
        quantityCounted: json["quantity_counted"],
        differenceQty: json["difference_qty"],
        uom: json["uom"],
        weight: json["weight"],
        isDoneItem: json["is_done_item"],
        dateTransaction: json["date_transaction"],
        observation: json["observation"],
        time: json["time"],
        userOperatorId: json["user_operator_id"],
        userOperatorName: json["user_operator_name"],
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        lotId: json["lot_id"],
        lotName: json["lot_name"],
        fechaVencimiento: json["fecha_vencimiento"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "product_name": productName,
        "product_code": productCode,
        "product_barcode": productBarcode,
        "product_tracking": productTracking,
        "other_barcodes": otherBarcodes == null
            ? []
            : List<dynamic>.from(otherBarcodes!.map((x) => x)),
        "product_packing": productPacking == null
            ? []
            : List<dynamic>.from(productPacking!.map((x) => x)),
        "location_id": locationId,
        "location_name": locationName,
        "location_barcode": locationBarcode,
        "quantity_inventory": quantityInventory,
        "quantity_counted": quantityCounted,
        "difference_qty": differenceQty,
        "uom": uom,
        "weight": weight,
        "is_done_item": isDoneItem,
        "date_transaction": dateTransaction,
        "observation": observation,
        "time": time,
        "user_operator_id": userOperatorId,
        "user_operator_name": userOperatorName,
        "category_id": categoryId,
        "category_name": categoryName,
        "lot_id": lotId,
        "lot_name": lotName,
        "fecha_vencimiento": fechaVencimiento,
      };
}
