import 'dart:convert';

class HistoryPicking {
    final String? jsonrpc;
    final dynamic id;
    final HistoryPickingResult? result;

    HistoryPicking({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory HistoryPicking.fromJson(String str) => HistoryPicking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistoryPicking.fromMap(Map<String, dynamic> json) => HistoryPicking(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : HistoryPickingResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class HistoryPickingResult {
    final int? code;
    final List<HistoryBatch>? result;

    HistoryPickingResult({
        this.code,
        this.result,
    });

    factory HistoryPickingResult.fromJson(String str) => HistoryPickingResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistoryPickingResult.fromMap(Map<String, dynamic> json) => HistoryPickingResult(
        code: json["code"],
        result: json["result"] == null ? [] : List<HistoryBatch>.from(json["result"]!.map((x) => HistoryBatch.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}

class HistoryBatch {
    final int? id;
    final String? name;
    final String? userName;
    final int? userId;
    final String? rol;
    final String? orderBy;
    final String? orderPicking;
    final dynamic? scheduleddate;
    final String? state;
    final String? pickingTypeId;
    final String? observation;
    final bool? isWave;
    final String? muelle;
    final String? idMuelle;
    final int? countItems;
    final dynamic? totalQuantityItems;
    final dynamic? itemsSeparado;

    HistoryBatch({
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
        this.isWave,
        this.muelle,
        this.idMuelle,
        this.countItems,
        this.totalQuantityItems,
        this.itemsSeparado,
    });

    factory HistoryBatch.fromJson(String str) => HistoryBatch.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HistoryBatch.fromMap(Map<String, dynamic> json) => HistoryBatch(
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
        isWave: json["is_wave"],
        muelle: json["muelle"],
        idMuelle: json["id_muelle"],
        countItems: json["count_items"],
        totalQuantityItems: json["total_quantity_items"],
        itemsSeparado: json["items_separado"],
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
        "is_wave": isWave,
        "muelle": muelle,
        "id_muelle": idMuelle,
        "count_items": countItems,
        "total_quantity_items": totalQuantityItems,
        "items_separado": itemsSeparado,
    };
}
