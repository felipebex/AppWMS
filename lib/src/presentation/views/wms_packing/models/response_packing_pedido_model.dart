import 'dart:convert';

class PackingPedido {
    final String? jsonrpc;
    final dynamic id;
    final PackingPedidoResult? result;

    PackingPedido({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory PackingPedido.fromJson(String str) => PackingPedido.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PackingPedido.fromMap(Map<String, dynamic> json) => PackingPedido(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : PackingPedidoResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class PackingPedidoResult {
    final int? code;
    final List<PedidoPackingResult>? result;

    PackingPedidoResult({
        this.code,
        this.result,
    });

    factory PackingPedidoResult.fromJson(String str) => PackingPedidoResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PackingPedidoResult.fromMap(Map<String, dynamic> json) => PackingPedidoResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<PedidoPackingResult>.from(json["result"]!.map((x) => PedidoPackingResult.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class PedidoPackingResult {
    final int? batchId;
    final int? id;
    final String? name;
    final DateTime? fechaCreacion;
    final int? locationId;
    final LocationName? locationName;
    final LocationBarcode? locationBarcode;
    final int? locationDestId;
    final LocationDestName? locationDestName;
    final String? locationDestBarcode;
    final String? proveedor;
    final String? numeroTransferencia;
    final int? pesoTotal;
    final int? numeroLineas;
    final dynamic? numeroItems;
    final String? state;
    final String? referencia;
    final String? contacto;
    final String? contactoName;
    final int? cantidadProductos;
    final int? cantidadProductosTotal;
    final String? priority;
    final int? warehouseId;
    final String? warehouseName;
    final int? responsableId;
    final String? responsable;
    final String? pickingType;
    final String? startTimeTransfer;
    final String? endTimeTransfer;
    final int? backorderId;
    final String? backorderName;
    final dynamic? showCheckAvailability;
    final String? orderTms;
    final String? zonaEntregaTms;
    final String? zonaEntrega;
    final int? numeroPaquetes;

    // is_terminate
    final dynamic? isTerminate;
    // is_selected
    final dynamic? isSelected;




    final List<ListaProducto>? listaProductos;
    final List<dynamic>? listaProductosEnviadas;
    final List<ListaPaquete>? listaPaquetes;

    PedidoPackingResult({
        this.batchId,
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
        this.referencia,
        this.contacto,
        this.contactoName,
        this.cantidadProductos,
        this.cantidadProductosTotal,
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
        this.orderTms,
        this.zonaEntregaTms,
        this.zonaEntrega,
        this.numeroPaquetes,
        this.listaProductos,
        this.listaProductosEnviadas,
        this.listaPaquetes,
        this.isTerminate,
        this.isSelected,
    });

    factory PedidoPackingResult.fromJson(String str) => PedidoPackingResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PedidoPackingResult.fromMap(Map<String, dynamic> json) => PedidoPackingResult(
        batchId: json["batch_id"],
        id: json["id"],
        name: json["name"],
        fechaCreacion: json["fecha_creacion"] == null ? null : DateTime.parse(json["fecha_creacion"]),
        locationId: json["location_id"],
        locationName: locationNameValues.map[json["location_name"]],
        locationBarcode: locationBarcodeValues.map[json["location_barcode"]],
        locationDestId: json["location_dest_id"],
        locationDestName: locationDestNameValues.map[json["location_dest_name"]],
        locationDestBarcode: json["location_dest_barcode"],
        proveedor: json["proveedor"],
        numeroTransferencia: json["numero_transferencia"],
        pesoTotal: json["peso_total"],
        numeroLineas: json["numero_lineas"],
        numeroItems: json["numero_items"],
        state: json["state"],
        referencia: json["referencia"],
        contacto: json["contacto"],
        contactoName: json["contacto_name"],
        cantidadProductos: json["cantidad_productos"],
        cantidadProductosTotal: json["cantidad_productos_total"],
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
        orderTms: json["order_tms"],
        zonaEntregaTms: json["zona_entrega_tms"],
        zonaEntrega: json["zona_entrega"],
        numeroPaquetes: json["numero_paquetes"],
        isTerminate: json["is_terminate"],
        isSelected: json["is_selected"],
        listaProductos: json["lista_productos"] == null ? [] : List<ListaProducto>.from(json["lista_productos"]!.map((x) => ListaProducto.fromMap(x))),
        listaProductosEnviadas: json["lista_productos_enviadas"] == null ? [] : List<dynamic>.from(json["lista_productos_enviadas"]!.map((x) => x)),
        listaPaquetes: json["lista_paquetes"] == null ? [] : List<ListaPaquete>.from(json["lista_paquetes"]!.map((x) => ListaPaquete.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "batch_id": batchId,
        "id": id,
        "name": name,
        "fecha_creacion": fechaCreacion?.toIso8601String(),
        "location_id": locationId,
        "location_name": locationNameValues.reverse[locationName],
        "location_barcode": locationBarcodeValues.reverse[locationBarcode],
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestNameValues.reverse[locationDestName],
        "location_dest_barcode": locationDestBarcode,
        "proveedor": proveedor,
        "numero_transferencia": numeroTransferencia,
        "peso_total": pesoTotal,
        "numero_lineas": numeroLineas,
        "numero_items": numeroItems,
        "state": state,
        "referencia": referencia,
        "contacto": contacto,
        "contacto_name": contactoName,
        "cantidad_productos": cantidadProductos,
        "cantidad_productos_total": cantidadProductosTotal,
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
        "order_tms": orderTms,
        "zona_entrega_tms": zonaEntregaTms,
        "zona_entrega": zonaEntrega,
        "numero_paquetes": numeroPaquetes,
        "is_terminate": isTerminate,
        "is_selected": isSelected,
        "lista_productos": listaProductos == null ? [] : List<dynamic>.from(listaProductos!.map((x) => x.toMap())),
        "lista_productos_enviadas": listaProductosEnviadas == null ? [] : List<dynamic>.from(listaProductosEnviadas!.map((x) => x)),
        "lista_paquetes": listaPaquetes == null ? [] : List<dynamic>.from(listaPaquetes!.map((x) => x.toMap())),
    };
}

class ListaPaquete {
    final String? name;
    final int? id;
    final int? batchId;
    final int? pedidoId;
    final int? cantidadProductos;
    final List<ListaProductosInPacking>? listaProductosInPacking;
    final bool? isSticker;
    final bool? isCertificate;
    final DateTime? fechaCreacion;
    final DateTime? fechaActualizacion;

    ListaPaquete({
        this.name,
        this.id,
        this.batchId,
        this.pedidoId,
        this.cantidadProductos,
        this.listaProductosInPacking,
        this.isSticker,
        this.isCertificate,
        this.fechaCreacion,
        this.fechaActualizacion,
    });

    factory ListaPaquete.fromJson(String str) => ListaPaquete.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListaPaquete.fromMap(Map<String, dynamic> json) => ListaPaquete(
        name: json["name"],
        id: json["id"],
        batchId: json["batch_id"],
        pedidoId: json["pedido_id"],
        cantidadProductos: json["cantidad_productos"],
        listaProductosInPacking: json["lista_productos_in_packing"] == null ? [] : List<ListaProductosInPacking>.from(json["lista_productos_in_packing"]!.map((x) => ListaProductosInPacking.fromMap(x))),
        isSticker: json["is_sticker"],
        isCertificate: json["is_certificate"],
        fechaCreacion: json["fecha_creacion"] == null ? null : DateTime.parse(json["fecha_creacion"]),
        fechaActualizacion: json["fecha_actualizacion"] == null ? null : DateTime.parse(json["fecha_actualizacion"]),
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "batch_id": batchId,
        "pedido_id": pedidoId,
        "cantidad_productos": cantidadProductos,
        "lista_productos_in_packing": listaProductosInPacking == null ? [] : List<dynamic>.from(listaProductosInPacking!.map((x) => x.toMap())),
        "is_sticker": isSticker,
        "is_certificate": isCertificate,
        "fecha_creacion": "${fechaCreacion!.year.toString().padLeft(4, '0')}-${fechaCreacion!.month.toString().padLeft(2, '0')}-${fechaCreacion!.day.toString().padLeft(2, '0')}",
        "fecha_actualizacion": "${fechaActualizacion!.year.toString().padLeft(4, '0')}-${fechaActualizacion!.month.toString().padLeft(2, '0')}-${fechaActualizacion!.day.toString().padLeft(2, '0')}",
    };
}

class ListaProductosInPacking {
    final int? idMove;
    final int? pedidoId;
    final int? batchId;
    final String? packageName;
    final dynamic? quantitySeparate;
    final int? idProduct;
    final List<dynamic>? productId;
    final String? namePacking;
    final dynamic? cantidadEnviada;
    final Uom? unidades;
    final dynamic? peso;
    final List<dynamic>? loteId;
    final Observacion? observacion;
    final dynamic? weight;
    final bool? isSticker;
    final bool? isCertificate;
    final int? idPackage;
    final dynamic? quantity;
    final Tracking? tracking;

    ListaProductosInPacking({
        this.idMove,
        this.pedidoId,
        this.batchId,
        this.packageName,
        this.quantitySeparate,
        this.idProduct,
        this.productId,
        this.namePacking,
        this.cantidadEnviada,
        this.unidades,
        this.peso,
        this.loteId,
        this.observacion,
        this.weight,
        this.isSticker,
        this.isCertificate,
        this.idPackage,
        this.quantity,
        this.tracking,
    });

    factory ListaProductosInPacking.fromJson(String str) => ListaProductosInPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListaProductosInPacking.fromMap(Map<String, dynamic> json) => ListaProductosInPacking(
        idMove: json["id_move"],
        pedidoId: json["pedido_id"],
        batchId: json["batch_id"],
        packageName: json["package_name"],
        quantitySeparate: json["quantity_separate"]?.toDouble(),
        idProduct: json["id_product"],
        productId: json["product_id"] == null ? [] : List<dynamic>.from(json["product_id"].map((x) => x)),
        namePacking: json["name_packing"],
        cantidadEnviada: json["cantidad_enviada"]?.toDouble(),
        unidades: uomValues.map[json["unidades"]]!,
        peso: json["peso"],
        loteId: json["lote_id"] == null ? [] : List<dynamic>.from(json["lote_id"]!.map((x) => x)),
        observacion: observacionValues.map[json["observacion"]]!,
        weight: json["weight"],
        isSticker: json["is_sticker"],
        isCertificate: json["is_certificate"],
        idPackage: json["id_package"],
        quantity: json["quantity"]?.toDouble(),
        tracking: trackingValues.map[json["tracking"]]!,
    );

    Map<String, dynamic> toMap() => {
        "id_move": idMove,
        "pedido_id": pedidoId,
        "batch_id": batchId,
        "package_name": packageName,
        "quantity_separate": quantitySeparate,
        "id_product": idProduct,
        "product_id": productId == null ? [] : List<dynamic>.from(productId!.map((x) => x)),
        "name_packing": namePacking,
        "cantidad_enviada": cantidadEnviada,
        "unidades": uomValues.reverse[unidades],
        "peso": peso,
        "lote_id": loteId == null ? [] : List<dynamic>.from(loteId!.map((x) => x)),
        "observacion": observacionValues.reverse[observacion],
        "weight": weight,
        "is_sticker": isSticker,
        "is_certificate": isCertificate,
        "id_package": idPackage,
        "quantity": quantity,
        "tracking": trackingValues.reverse[tracking],
    };
}

enum Observacion {
    AVERIADO,
    SIN_NOVEDAD,
    STOCK_INSUFICIENTE
}

final observacionValues = EnumValues({
    "Averiado": Observacion.AVERIADO,
    "Sin novedad": Observacion.SIN_NOVEDAD,
    "Stock insuficiente": Observacion.STOCK_INSUFICIENTE
});

enum Tracking {
    NONE
}

final trackingValues = EnumValues({
    "none": Tracking.NONE
});

enum Uom {
    UND,
    UNIDADES
}

final uomValues = EnumValues({
    "UND": Uom.UND,
    "Unidades": Uom.UNIDADES
});

class ListaProducto {
    final int? id;
    final int? idMove;
    final int? idTransferencia;
    final int? productId;
    final String? productName;
    final String? productCode;
    final String? productBarcode;
    final Tracking? productTracking;
    final String? diasVencimiento;
    final List<dynamic>? otherBarcodes;
    final List<dynamic>? productPacking;
    final dynamic? quantityOrdered;
    final dynamic? quantityToTransfer;
    final double? cantidadFaltante;
    final Uom? uom;
    final int? locationDestId;
    final LocationDestName? locationDestName;
    final String? locationDestBarcode;
    final int? locationId;
    final LocationName? locationName;
    final LocationBarcode? locationBarcode;
    final dynamic? weight;
    final bool? isDoneItem;
    final String? dateTransaction;
    final String? observation;
    final dynamic? time;
    final int? userOperatorId;
    final int? lotId;
    final String? lotName;
    final String? fechaVencimiento;

    ListaProducto({
        this.id,
        this.idMove,
        this.idTransferencia,
        this.productId,
        this.productName,
        this.productCode,
        this.productBarcode,
        this.productTracking,
        this.diasVencimiento,
        this.otherBarcodes,
        this.productPacking,
        this.quantityOrdered,
        this.quantityToTransfer,
        this.cantidadFaltante,
        this.uom,
        this.locationDestId,
        this.locationDestName,
        this.locationDestBarcode,
        this.locationId,
        this.locationName,
        this.locationBarcode,
        this.weight,
        this.isDoneItem,
        this.dateTransaction,
        this.observation,
        this.time,
        this.userOperatorId,
        this.lotId,
        this.lotName,
        this.fechaVencimiento,
    });

    factory ListaProducto.fromJson(String str) => ListaProducto.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListaProducto.fromMap(Map<String, dynamic> json) => ListaProducto(
        id: json["id"],
        idMove: json["id_move"],
        idTransferencia: json["id_transferencia"],
        productId: json["product_id"],
        productName: json["product_name"],
        productCode: json["product_code"],
        productBarcode: json["product_barcode"],
        productTracking: trackingValues.map[json["product_tracking"]]!,
        diasVencimiento: json["dias_vencimiento"],
        otherBarcodes: json["other_barcodes"] == null ? [] : List<dynamic>.from(json["other_barcodes"].map((x) => x)),
        productPacking: json["product_packing"] == null ? [] : List<dynamic>.from(json["product_packing"].map((x) => x)),
        quantityOrdered: json["quantity_ordered"],
        quantityToTransfer: json["quantity_to_transfer"],
        cantidadFaltante: json["cantidad_faltante"]?.toDouble(),
        uom: uomValues.map[json["uom"]],
        locationDestId: json["location_dest_id"],
        locationDestName: locationDestNameValues.map[json["location_dest_name"]],
        locationDestBarcode: json["location_dest_barcode"],
        locationId: json["location_id"],
        locationName: locationNameValues.map[json["location_name"]],
        locationBarcode: locationBarcodeValues.map[json["location_barcode"]],
        weight: json["weight"],
        isDoneItem: json["is_done_item"],
        dateTransaction: json["date_transaction"],
        observation: json["observation"],
        time: json["time"],
        userOperatorId: json["user_operator_id"],
        lotId: json["lot_id"],
        lotName: json["lot_name"],
        fechaVencimiento: json["fecha_vencimiento"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "id_move": idMove,
        "id_transferencia": idTransferencia,
        "product_id": productId,
        "product_name": productName,
        "product_code": productCode,
        "product_barcode": productBarcode,
        "product_tracking": trackingValues.reverse[productTracking],
        "dias_vencimiento": diasVencimiento,
        "other_barcodes": otherBarcodes == null ? [] : List<dynamic>.from(otherBarcodes!.map((x) => x)),
        "product_packing": productPacking == null ? [] : List<dynamic>.from(productPacking!.map((x) => x)),
        "quantity_ordered": quantityOrdered,
        "quantity_to_transfer": quantityToTransfer,
        "cantidad_faltante": cantidadFaltante,
        "uom": uomValues.reverse[uom],
        "location_dest_id": locationDestId,
        "location_dest_name": locationDestNameValues.reverse[locationDestName],
        "location_dest_barcode": locationDestBarcode,
        "location_id": locationId,
        "location_name": locationNameValues.reverse[locationName],
        "location_barcode": locationBarcodeValues.reverse[locationBarcode],
        "weight": weight,
        "is_done_item": isDoneItem,
        "date_transaction": dateTransaction,
        "observation": observation,
        "time": time,
        "user_operator_id": userOperatorId,
        "lot_id": lotId,
        "lot_name": lotName,
        "fecha_vencimiento": fechaVencimiento,
    };
}

enum LocationBarcode {
    EMPTY,
    WH_OUTPUT
}

final locationBarcodeValues = EnumValues({
    "": LocationBarcode.EMPTY,
    "WH-OUTPUT": LocationBarcode.WH_OUTPUT
});

enum LocationDestName {
    PARTNERS_CUSTOMERS
}

final locationDestNameValues = EnumValues({
    "Partners/Customers": LocationDestName.PARTNERS_CUSTOMERS
});

enum LocationName {
    WP_SALIDA,
    WP_SALIDA_MUELLE_03_PRUEBA
}

final locationNameValues = EnumValues({
    "WP/Salida": LocationName.WP_SALIDA,
    "WP/Salida/Muelle-03-Prueba": LocationName.WP_SALIDA_MUELLE_03_PRUEBA
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
