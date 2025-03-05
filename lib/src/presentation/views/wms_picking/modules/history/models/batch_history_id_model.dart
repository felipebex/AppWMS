// ignore_for_file: unnecessary_question_mark

import 'dart:convert';

class HistorBatchId {
    final String? jsonrpc;
    final dynamic id;
    final HistorBatchIdResult? result;

    HistorBatchId({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory HistorBatchId.fromJson(String str) => HistorBatchId.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistorBatchId.fromMap(Map<String, dynamic> json) => HistorBatchId(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : HistorBatchIdResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class HistorBatchIdResult {
    final int? code;
    final HistoryBatchId? result;

    HistorBatchIdResult({
        this.code,
        this.result,
    });

    factory HistorBatchIdResult.fromJson(String str) => HistorBatchIdResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistorBatchIdResult.fromMap(Map<String, dynamic> json) => HistorBatchIdResult(
        code: json["code"],
        result: json["result"] == null ? null : HistoryBatchId.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result?.toMap(),
    };
}

class HistoryBatchId {
    final int? id;
    final String? name;
    final String? userName;
    final int? userId;
    final String? rol;
    final String? orderBy;
    final String? orderPicking;
    final DateTime? scheduleddate;
    final String? state;
    final String? pickingTypeId;
    final String? observation;
    final String? muelle;
    final dynamic? idMuelle;
    final dynamic? countItems;
    final dynamic? totalQuantityItems;
    final dynamic? itemsSeparado;
    final List<ListItem>? listItems;

    HistoryBatchId({
        this.id,
        this.name,
        this.userName,
        this.userId,
        this.rol,
        this.orderBy,
        this.orderPicking,
        this.scheduleddate,
        this.state,
        this.pickingTypeId,
        this.observation,
        this.muelle,
        this.idMuelle,
        this.countItems,
        this.totalQuantityItems,
        this.itemsSeparado,
        this.listItems,
    });

    factory HistoryBatchId.fromJson(String str) => HistoryBatchId.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistoryBatchId.fromMap(Map<String, dynamic> json) => HistoryBatchId(
        id: json["id"],
        name: json["name"],
        userName: json["user_name"],
        userId: json["user_id"],
        rol: json["rol"],
        orderBy: json["order_by"],
        orderPicking: json["order_picking"],
        scheduleddate: json["scheduleddate"] == null ? null : DateTime.parse(json["scheduleddate"]),
        state: json["state"],
        pickingTypeId: json["picking_type_id"],
        observation: json["observation"],
        muelle: json["muelle"],
        idMuelle: json["id_muelle"],
        countItems: json["count_items"],
        totalQuantityItems: json["total_quantity_items"],
        itemsSeparado: json["items_separado"],
        listItems: json["list_items"] == null ? [] : List<ListItem>.from(json["list_items"]!.map((x) => ListItem.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "user_name": userName,
        "user_id": userId,
        "rol": rol,
        "order_by": orderBy,
        "order_picking": orderPicking,
        "scheduleddate": scheduleddate?.toIso8601String(),
        "state": state,
        "picking_type_id": pickingTypeId,
        "observation": observation,
        "muelle": muelle,
        "id_muelle": idMuelle,
        "count_items": countItems,
        "total_quantity_items": totalQuantityItems,
        "items_separado": itemsSeparado,
        "list_items": listItems == null ? [] : List<dynamic>.from(listItems!.map((x) => x.toMap())),
    };
}

class ListItem {
    final int? batchId;
    final int? idMove;
    final int? pickingId;
    final int? idProduct;
    final List<dynamic>? productId;
    final dynamic? loteId;
    final List<dynamic>? lotId;
    final List<dynamic>? locationId;
    final String? barcodeLocation;
    final List<dynamic>? locationDestId;
    final String? barcodeLocationDest;
    final dynamic? quantity;
    final dynamic? quantityDone;
    final DateTime? fechaTransaccion;
    final String? observation;
    final String? timeLine;
    final int? operatorId;
    final bool? doneItem;
    final dynamic? weight;
    final String? unidades;

    ListItem({
        this.batchId,
        this.idMove,
        this.pickingId,
        this.idProduct,
        this.productId,
        this.loteId,
        this.lotId,
        this.locationId,
        this.barcodeLocation,
        this.locationDestId,
        this.barcodeLocationDest,
        this.quantity,
        this.quantityDone,
        this.fechaTransaccion,
        this.observation,
        this.timeLine,
        this.operatorId,
        this.doneItem,
        this.weight,
        this.unidades,
    });

    factory ListItem.fromJson(String str) => ListItem.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListItem.fromMap(Map<String, dynamic> json) => ListItem(
        batchId: json["batch_id"],
        idMove: json["id_move"],
        pickingId: json["picking_id"],
        idProduct: json["id_product"],
        productId: json["product_id"] == null ? [] : List<dynamic>.from(json["product_id"]!.map((x) => x)),
        loteId: json["lote_id"],
        lotId: json["lot_id"] == null ? [] : List<dynamic>.from(json["lot_id"]!.map((x) => x)),
        locationId: json["location_id"] == null ? [] : List<dynamic>.from(json["location_id"]!.map((x) => x)),
        barcodeLocation: json["barcode_location"],
        locationDestId: json["location_dest_id"] == null ? [] : List<dynamic>.from(json["location_dest_id"]!.map((x) => x)),
        barcodeLocationDest: json["barcode_location_dest"],
        quantity: json["quantity"],
        quantityDone: json["quantity_done"],
        fechaTransaccion: json["fecha_transaccion"] == null ? null : DateTime.parse(json["fecha_transaccion"]),
        observation: json["observation"],
        timeLine: json["time_line"],
        operatorId: json["operator_id"],
        doneItem: json["done_item"],
        weight: json["weight"],
        unidades: json["unidades"],
    );

    Map<String, dynamic> toMap() => {
        "batch_id": batchId,
        "id_move": idMove,
        "picking_id": pickingId,
        "id_product": idProduct,
        "product_id": productId == null ? [] : List<dynamic>.from(productId!.map((x) => x)),
        "lote_id": loteId,
        "lot_id": lotId == null ? [] : List<dynamic>.from(lotId!.map((x) => x)),
        "location_id": locationId == null ? [] : List<dynamic>.from(locationId!.map((x) => x)),
        "barcode_location": barcodeLocation,
        "location_dest_id": locationDestId == null ? [] : List<dynamic>.from(locationDestId!.map((x) => x)),
        "barcode_location_dest": barcodeLocationDest,
        "quantity": quantity,
        "quantity_done": quantityDone,
        "fecha_transaccion": fechaTransaccion?.toIso8601String(),
        "observation": observation,
        "time_line": timeLine,
        "operator_id": operatorId,
        "done_item": doneItem,
        "weight": weight,
        "unidades": unidades,
    };
}
