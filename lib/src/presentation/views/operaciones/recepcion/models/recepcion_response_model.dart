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
    List<OrdenCompra>? result;

    RecepcionresponseResult({
        this.code,
        this.result,
    });

    factory RecepcionresponseResult.fromMap(Map<String, dynamic> json) => RecepcionresponseResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<OrdenCompra>.from(json["result"]!.map((x) => OrdenCompra.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class OrdenCompra {
    int? id;
    String? name;
    String? fechaCreacion;
    String? scheduledDate;
    int? proveedorId;
    String? proveedor;
    int? locationDestId;
    String? locationDestName;
    int? purchaseOrderId;
    String? purchaseOrderName;
    String? numeroEntrada;
    double? pesoTotal;
    dynamic numeroLineas;
    dynamic numeroItems;
    String? state;
    dynamic origin;
    String? priority;
    int? warehouseId;
    String? warehouseName;
    int? locationId;
    String? locationName;
    dynamic responsableId;
    dynamic responsable;
    String? pickingType;
    List<LineasRecepcion>? lineasRecepcion;

    OrdenCompra({
        this.id,
        this.name,
        this.fechaCreacion,
        this.scheduledDate,
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

    factory OrdenCompra.fromMap(Map<String, dynamic> json) => OrdenCompra(
        id: json["id"],
        name: json["name"],
        fechaCreacion: json["fecha_creacion"],
        scheduledDate: json["scheduled_date"],
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
        "scheduled_date": scheduledDate,
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
    String? productName;
    String? productCode;
    String? productBarcode;
    String? productTracking;
    List<dynamic>? otherBarcodes;
    List<dynamic>? productPacking;
    dynamic quantityOrdered;
    dynamic quantityToReceive;
    dynamic quantityDone;
    dynamic priceUnit;
    String? uom;
    double? weight;
    List<DetalleLinea>? detalleLineas;

    LineasRecepcion({
        this.id,
        this.productId,
        this.productName,
        this.productCode,
        this.productBarcode,
        this.productTracking,
        this.otherBarcodes,
        this.productPacking,
        this.quantityOrdered,
        this.quantityToReceive,
        this.quantityDone,
        this.priceUnit,
        this.uom,
        this.weight,
        this.detalleLineas,
    });

    factory LineasRecepcion.fromMap(Map<String, dynamic> json) => LineasRecepcion(
        id: json["id"],
        productId: json["product_id"],
        productName: json["product_name"],
        productCode: json["product_code"],
        productBarcode: json["product_barcode"],
        productTracking: json["product_tracking"],
        otherBarcodes: json["other_barcodes"] == null ? [] : List<dynamic>.from(json["other_barcodes"]!.map((x) => x)),
        productPacking: json["product_packing"] == null ? [] : List<dynamic>.from(json["product_packing"]!.map((x) => x)),
        quantityOrdered: json["quantity_ordered"],
        quantityToReceive: json["quantity_to_receive"],
        quantityDone: json["quantity_done"],
        priceUnit: json["price_unit"],
        uom: json["uom"],
        weight: json["weight"]?.toDouble(),
        detalleLineas: json["detalle_lineas"] == null ? [] : List<DetalleLinea>.from(json["detalle_lineas"]!.map((x) => DetalleLinea.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "product_id": productId,
        "product_name": productName,
        "product_code": productCode,
        "product_barcode": productBarcode,
        "product_tracking": productTracking,
        "other_barcodes": otherBarcodes == null ? [] : List<dynamic>.from(otherBarcodes!.map((x) => x)),
        "product_packing": productPacking == null ? [] : List<dynamic>.from(productPacking!.map((x) => x)),
        "quantity_ordered": quantityOrdered,
        "quantity_to_receive": quantityToReceive,
        "quantity_done": quantityDone,
        "price_unit": priceUnit,
        "uom": uom,
        "weight": weight,
        "detalle_lineas": detalleLineas == null ? [] : List<dynamic>.from(detalleLineas!.map((x) => x.toMap())),
    };
}

class DetalleLinea {
    int? id;
    dynamic qtyDone;
    dynamic qtyTodo;
    dynamic productUomQty;
    dynamic lotId;
    String? lotName;
    String? expirationDate;
    int? locationId;
    String? locationName;
    String? locationBarcode;
    int? locationDestId;
    String? locationDestName;
    String? locationDestBarcode;
    int? packageId;
    String? packageName;
    int? resultPackageId;
    String? resultPackageName;

    DetalleLinea({
        this.id,
        this.qtyDone,
        this.qtyTodo,
        this.productUomQty,
        this.lotId,
        this.lotName,
        this.expirationDate,
        this.locationId,
        this.locationName,
        this.locationBarcode,
        this.locationDestId,
        this.locationDestName,
        this.locationDestBarcode,
        this.packageId,
        this.packageName,
        this.resultPackageId,
        this.resultPackageName,
    });

    factory DetalleLinea.fromMap(Map<String, dynamic> json) => DetalleLinea(
        id: json["id"],
        qtyDone: json["qty_done"],
        qtyTodo: json["qty_todo"],
        productUomQty: json["product_uom_qty"],
        lotId: json["lot_id"],
        lotName: json["lot_name"],
        expirationDate: json["expiration_date"],
        locationId: json["location_id"],
        locationName: json["location_name"],
        locationBarcode: json["location_barcode"],
        locationDestId: json["location_dest_id"],
        locationDestName: json["location_dest_name"],
        locationDestBarcode: json["location_dest_barcode"],
        packageId: json["package_id"],
        packageName: json["package_name"],
        resultPackageId: json["result_package_id"],
        resultPackageName: json["result_package_name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "qty_done": qtyDone,
        "qty_todo": qtyTodo,
        "product_uom_qty": productUomQty,
        "lot_id": lotId,
        "lot_name": lotName,
        "expiration_date": expirationDate,
        "location_id": locationId,
        "location_name": locationName,
        "location_barcode": locationBarcode,
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestName,
        "location_dest_barcode": locationDestBarcode,
        "package_id": packageId,
        "package_name": packageName,
        "result_package_id": resultPackageId,
        "result_package_name": resultPackageName,
    };
}
