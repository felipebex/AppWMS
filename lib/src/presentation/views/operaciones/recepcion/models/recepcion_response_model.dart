

// To parse this JSON data, do
//
//     final recepcionresponse = recepcionresponseFromMap(jsonString);

import 'dart:convert';

Recepcionresponse recepcionresponseFromMap(String str) => Recepcionresponse.fromMap(json.decode(str));

String recepcionresponseToMap(Recepcionresponse data) => json.encode(data.toMap());

class Recepcionresponse {
    String? jsonrpc;
    dynamic id;
    RecepcionresponseResult? result;

    Recepcionresponse({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory Recepcionresponse.fromMap(Map<String, dynamic> json) => Recepcionresponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : RecepcionresponseResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class RecepcionresponseResult {
    int? code;
    List<ResultEntrada>? result;

    RecepcionresponseResult({
        this.code,
        this.result,
    });

    factory RecepcionresponseResult.fromMap(Map<String, dynamic> json) => RecepcionresponseResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<ResultEntrada>.from(json["result"]!.map((x) => ResultEntrada.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class ResultEntrada {
    int? id;
    String? name;
    String? fechaCreacion;
    int? proveedorId;
    String? proveedor;
    int? locationDestId;
    String? locationDestName;
    int? purchaseOrderId;
    String? purchaseOrderName;
    String? numeroEntrada;
    double? pesoTotal;
    dynamic? numeroLineas;
    dynamic? numeroItems;
    String? state;
    String? origin;
    String? priority;
    int? warehouseId;
    String? warehouseName;
    int? locationId;
    String? locationName;
    int? responsableId;
    String? responsable;
    String? pickingType;
    List<LineasRecepcion>? lineasRecepcion;

    ResultEntrada({
        this.id,
        this.name,
        this.fechaCreacion,
        this.proveedorId,
        this.proveedor,
        this.locationDestId,
        this.locationDestName,
        this.purchaseOrderId,
        this.purchaseOrderName,
        this.numeroEntrada,
        this.pesoTotal,
        this.numeroLineas,
        this.numeroItems,
        this.state,
        this.origin,
        this.priority,
        this.warehouseId,
        this.warehouseName,
        this.locationId,
        this.locationName,
        this.responsableId,
        this.responsable,
        this.pickingType,
        this.lineasRecepcion,
    });

    factory ResultEntrada.fromMap(Map<String, dynamic> json) => ResultEntrada(
        id: json["id"],
        name: json["name"],
        fechaCreacion: json["fecha_creacion"],
        proveedorId: json["proveedor_id"],
        proveedor: json["proveedor"],
        locationDestId: json["location_dest_id"],
        locationDestName: json["location_dest_name"],
        purchaseOrderId: json["purchase_order_id"],
        purchaseOrderName: json["purchase_order_name"],
        numeroEntrada: json["numero_entrada"],
        pesoTotal: json["peso_total"]?.toDouble(),
        numeroLineas: json["numero_lineas"],
        numeroItems: json["numero_items"],
        state: json["state"],
        origin: json["origin"],
        priority: json["priority"],
        warehouseId: json["warehouse_id"],
        warehouseName: json["warehouse_name"],
        locationId: json["location_id"],
        locationName: json["location_name"],
        responsableId: json["responsable_id"],
        responsable: json["responsable"],
        pickingType: json["picking_type"],
        lineasRecepcion: json["lineas_recepcion"] == null ? [] : List<LineasRecepcion>.from(json["lineas_recepcion"]!.map((x) => LineasRecepcion.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "fecha_creacion": fechaCreacion,
        "proveedor_id": proveedorId,
        "proveedor": proveedor,
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestName,
        "purchase_order_id": purchaseOrderId,
        "purchase_order_name": purchaseOrderName,
        "numero_entrada": numeroEntrada,
        "peso_total": pesoTotal,
        "numero_lineas": numeroLineas,
        "numero_items": numeroItems,
        "state": state,
        "origin": origin,
        "priority": priority,
        "warehouse_id": warehouseId,
        "warehouse_name": warehouseName,
        "location_id": locationId,
        "location_name": locationName,
        "responsable_id": responsableId,
        "responsable": responsable,
        "picking_type": pickingType,
        "lineas_recepcion": lineasRecepcion == null ? [] : List<dynamic>.from(lineasRecepcion!.map((x) => x.toMap())),
    };
}

class LineasRecepcion {
    int? id;
    int? productId;
    int? idRecepcion;
    String? productName;
    String? productCode;
    String? productBarcode;
    String? productTracking;
    String? fechaVencimiento;
    
    int? diasVencimiento;
    List<OtherBarcode>? otherBarcodes;
    List<dynamic>? productPacking;
    dynamic? quantityOrdered;
    dynamic? quantityToReceive;
    dynamic? quantityDone;
    String? uom;
    int? locationDestId;
    String? locationDestName;
    String? locationBarcode;
    int? locationId;
    String? locationName;
    double? weight;

    LineasRecepcion({
        this.id,
        this.productId,
        this.idRecepcion,
        this.productName,
        this.productCode,
        this.productBarcode,
        this.productTracking,
        this.fechaVencimiento,
        this.diasVencimiento,
        this.otherBarcodes,
        this.productPacking,
        this.quantityOrdered,
        this.quantityToReceive,
        this.quantityDone,
        this.uom,
        this.locationDestId,
        this.locationDestName,
        this.locationBarcode,
        this.locationId,
        this.locationName,
        this.weight,
    });

    factory LineasRecepcion.fromMap(Map<String, dynamic> json) => LineasRecepcion(
        id: json["id"],
        productId: json["product_id"],
        idRecepcion: json["id_recepcion"],
        productName: json["product_name"],
        productCode: json["product_code"],
        productBarcode: json["product_barcode"],
        productTracking: json["product_tracking"],
        fechaVencimiento: json["fecha_vencimiento"],
        diasVencimiento: json["dias_vencimiento"],
        otherBarcodes: json["other_barcodes"] == null ? [] : List<OtherBarcode>.from(json["other_barcodes"]!.map((x) => OtherBarcode.fromMap(x))),
        productPacking: json["product_packing"] == null ? [] : List<dynamic>.from(json["product_packing"]!.map((x) => x)),
        quantityOrdered: json["quantity_ordered"],
        quantityToReceive: json["quantity_to_receive"],
        quantityDone: json["quantity_done"],
        uom: json["uom"],
        locationDestId: json["location_dest_id"],
        locationDestName: json["location_dest_name"],
        locationBarcode: json["location_barcode"],
        locationId: json["location_id"],
        locationName: json["location_name"],
        weight: json["weight"]?.toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "product_id": productId,
        "id_recepcion": idRecepcion,
        "product_name": productName,
        "product_code": productCode,
        "product_barcode": productBarcode,
        "product_tracking": productTracking,
        "fecha_vencimiento": fechaVencimiento,
        "dias_vencimiento": diasVencimiento,
        "other_barcodes": otherBarcodes == null ? [] : List<dynamic>.from(otherBarcodes!.map((x) => x.toMap())),
        "product_packing": productPacking == null ? [] : List<dynamic>.from(productPacking!.map((x) => x)),
        "quantity_ordered": quantityOrdered,
        "quantity_to_receive": quantityToReceive,
        "quantity_done": quantityDone,
        "uom": uom,
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestName,
        "location_barcode": locationBarcode,
        "location_id": locationId,
        "location_name": locationName,
        "weight": weight,
    };
}

class OtherBarcode {
    String? barcode;
    int? idMove;
    int? idProduct;

    OtherBarcode({
        this.barcode,
        this.idMove,
        this.idProduct,
    });

    factory OtherBarcode.fromMap(Map<String, dynamic> json) => OtherBarcode(
        barcode: json["barcode"],
        idMove: json["id_move"],
        idProduct: json["id_product"],
    );

    Map<String, dynamic> toMap() => {
        "barcode": barcode,
        "id_move": idMove,
        "id_product": idProduct,
    };
}

