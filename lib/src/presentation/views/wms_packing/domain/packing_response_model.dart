import 'dart:convert';

class PackingModelResponse {
    final Data? data;

    PackingModelResponse({
        this.data,
    });

    factory PackingModelResponse.fromJson(String str) => PackingModelResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PackingModelResponse.fromMap(Map<String, dynamic> json) => PackingModelResponse(
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
    };
}

class Data {
    final int? code;
    final List<BatchPackingModel>? result;

    Data({
        this.code,
        this.result,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        code: json["code"],
        result: json["result"] == null ? [] : List<BatchPackingModel>.from(json["result"]!.map((x) => BatchPackingModel.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toMap())),
    };
}




class BatchPackingModel {
    final int? id;
    final String? name;
    final DateTime? scheduleddate;
    final String? pickingTypeId;
    final String? state;
    final dynamic? userId;
    final List<PedidoPacking>? listaPedidos;

    BatchPackingModel({
        this.id,
        this.name,
        this.scheduleddate,
        this.state,
        this.userId,
        this.pickingTypeId,
        this.listaPedidos,
    });

    factory BatchPackingModel.fromJson(String str) => BatchPackingModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory BatchPackingModel.fromMap(Map<String, dynamic> json) => BatchPackingModel(
        id: json["id"],
        name: json["name"],
        scheduleddate: json["scheduleddate"] == null ? null : DateTime.parse(json["scheduleddate"]),
        state: json["state"],
        userId: json["user_id"],
        pickingTypeId: json["picking_type_id"],
        listaPedidos: json["lista_pedidos"] == null ? [] : List<PedidoPacking>.from(json["lista_pedidos"]!.map((x) => PedidoPacking.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "scheduleddate": scheduleddate?.toIso8601String(),
        "state": state,
        "user_id": userId,
        "picking_type_id": pickingTypeId,
        "lista_pedidos": listaPedidos == null ? [] : List<dynamic>.from(listaPedidos!.map((x) => x.toMap())),
    };
}







class PedidoPacking {
    final int? id;
    final int? batchId;
    final String? name;
    final dynamic referencia;
    final List<dynamic>? contacto;
    final String? tipoOperacion;
    final int? cantidadProductos;
    final int? numeroPaquetes;
    final List<ListaProducto>? listaProductos;
    final List<ListaPaquete>? listaPaquetes;

    PedidoPacking({
        this.id,
        this.batchId,
        this.name,
        this.referencia,
        this.contacto,
        this.tipoOperacion,
        this.cantidadProductos,
        this.numeroPaquetes,
        this.listaProductos,
        this.listaPaquetes,
    });

    factory PedidoPacking.fromJson(String str) => PedidoPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PedidoPacking.fromMap(Map<String, dynamic> json) => PedidoPacking(
        id: json["id"],
        batchId: json["batch_id"],
        name: json["name"],
        referencia: json["referencia"],
        contacto: json["contacto"] == null ? [] : List<dynamic>.from(json["contacto"]!.map((x) => x)),
        tipoOperacion: json["tipo_operacion"],
        cantidadProductos: json["cantidad_productos"],
        numeroPaquetes: json["numero paquetes"],
        listaProductos: json["lista_productos"] == null ? [] : List<ListaProducto>.from(json["lista_productos"]!.map((x) => ListaProducto.fromMap(x))),
        listaPaquetes: json["lista_paquetes"] == null ? [] : List<ListaPaquete>.from(json["lista_paquetes"]!.map((x) => ListaPaquete.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "batch_id": batchId,
        "name": name,
        "referencia": referencia,
        "contacto": contacto == null ? [] : List<dynamic>.from(contacto!.map((x) => x)),
        "tipo_operacion": tipoOperacion,
        "cantidad_productos": cantidadProductos,
        "numero paquetes": numeroPaquetes,
        "lista_productos": listaProductos == null ? [] : List<dynamic>.from(listaProductos!.map((x) => x.toMap())),
        "lista_paquetes": listaPaquetes == null ? [] : List<dynamic>.from(listaPaquetes!.map((x) => x.toMap())),
    };
}


















class ListaPaquete {
    final String? name;
    final int? cantidadProductos;
    final List<dynamic>? listaProductos;
    final bool? isSticker;
    final DateTime? fechaCreacion;
    final DateTime? fechaActualiazacion;

    ListaPaquete({
        this.name,
        this.cantidadProductos,
        this.listaProductos,
        this.isSticker,
        this.fechaCreacion,
        this.fechaActualiazacion,
    });

    factory ListaPaquete.fromJson(String str) => ListaPaquete.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListaPaquete.fromMap(Map<String, dynamic> json) => ListaPaquete(
        name: json["name"],
        cantidadProductos: json["cantidad_productos"],
        listaProductos: json["lista_productos"] == null ? [] : List<dynamic>.from(json["lista_productos"]!.map((x) => x)),
        isSticker: json["is_sticker"],
        fechaCreacion: json["fecha_creacion"] == null ? null : DateTime.parse(json["fecha_creacion"]),
        fechaActualiazacion: json["fecha_actualiazacion"] == null ? null : DateTime.parse(json["fecha_actualiazacion"]),
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "cantidad_productos": cantidadProductos,
        "lista_productos": listaProductos == null ? [] : List<dynamic>.from(listaProductos!.map((x) => x)),
        "is_sticker": isSticker,
        "fecha_creacion": "${fechaCreacion!.year.toString().padLeft(4, '0')}-${fechaCreacion!.month.toString().padLeft(2, '0')}-${fechaCreacion!.day.toString().padLeft(2, '0')}",
        "fecha_actualiazacion": "${fechaActualiazacion!.year.toString().padLeft(4, '0')}-${fechaActualiazacion!.month.toString().padLeft(2, '0')}-${fechaActualiazacion!.day.toString().padLeft(2, '0')}",
    };
}

class ListaProducto {

    final int? productId;
    final int? batchId;
    final List<dynamic>? idProduct;
    final int? loteId;
    final dynamic lotId;
    final List<dynamic>? locationId;
    final List<dynamic>? locationDestId;
    final double? quantity;
    final String? tracking;
    final dynamic barcode;
    final List<ProductPacking>? productPacking;
    final dynamic? weight;
    final String? unidades;

    ListaProducto({
        this.productId,
        this.batchId,
        this.idProduct,
        this.loteId,
        this.lotId,
        this.locationId,
        this.locationDestId,
        this.quantity,
        this.tracking,
        this.barcode,
        this.productPacking,
        this.weight,
        this.unidades,
    });

    factory ListaProducto.fromJson(String str) => ListaProducto.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ListaProducto.fromMap(Map<String, dynamic> json) => ListaProducto(
        productId: json["product_id"],
        batchId: json["batch_id"],
        idProduct: json["id_product"] == null ? [] : List<dynamic>.from(json["id_product"]!.map((x) => x)),
        loteId: json["lote_id"],
        lotId: json["lot_id"],
        locationId: json["location_id"] == null ? [] : List<dynamic>.from(json["location_id"]!.map((x) => x)),
        locationDestId: json["location_dest_id"] == null ? [] : List<dynamic>.from(json["location_dest_id"]!.map((x) => x)),
        quantity: json["quantity"],
        tracking: json["tracking"],
        barcode: json["barcode"],
        productPacking: json["product_packing"] == null ? [] : List<ProductPacking>.from(json["product_packing"]!.map((x) => ProductPacking.fromMap(x))),
        weight: json["weight"],
        unidades: json["unidades"] 
    );

    Map<String, dynamic> toMap() => {
        "product_id": productId,
        "batch_id": batchId,
        "id_product": idProduct == null ? [] : List<dynamic>.from(idProduct!.map((x) => x)),
        "lote_id": loteId,
        "lot_id": lotId,
        "location_id": locationId == null ? [] : List<dynamic>.from(locationId!.map((x) => x)),
        "location_dest_id": locationDestId == null ? [] : List<dynamic>.from(locationDestId!.map((x) => x)),
        "quantity": quantity,
        "tracking": tracking,
        "barcode": barcode,
        "product_packing": productPacking == null ? [] : List<dynamic>.from(productPacking!.map((x) => x.toMap())),
        "weight": weight,
        "unidades": unidades
    };
}

enum LocationDestIdEnum {
    PARTNERS_CUSTOMERS,
    PARTNERS_VENDORS
}

final locationDestIdEnumValues = EnumValues({
    "Partners/Customers": LocationDestIdEnum.PARTNERS_CUSTOMERS,
    "Partners/Vendors": LocationDestIdEnum.PARTNERS_VENDORS
});

enum LocationIdEnum {
    MD_SALIDA,
    PG_EXISTENCIAS_MATERIA_PRIMA,
    SS_EXISTENCIAS_PRODUCTO_TERMINADO
}

final locationIdEnumValues = EnumValues({
    "MD/Salida": LocationIdEnum.MD_SALIDA,
    "PG/Existencias/Materia Prima": LocationIdEnum.PG_EXISTENCIAS_MATERIA_PRIMA,
    "SS/Existencias/Producto Terminado": LocationIdEnum.SS_EXISTENCIAS_PRODUCTO_TERMINADO
});

class ProductPacking {
    final dynamic barcode;
    final double? cantidad;

    ProductPacking({
        this.barcode,
        this.cantidad,
    });

    factory ProductPacking.fromJson(String str) => ProductPacking.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ProductPacking.fromMap(Map<String, dynamic> json) => ProductPacking(
        barcode: json["barcode"],
        cantidad: json["cantidad"],
    );

    Map<String, dynamic> toMap() => {
        "barcode": barcode,
        "cantidad": cantidad,
    };
}

enum PickingTypeId {
    CEDI_MEDELLIN_RDENES_DE_ENTREGA,
    PAISAPAN_RDENES_DE_ENTREGA,
    SAN_SEBASTIAN_RDENES_DE_ENTREGA
}

final pickingTypeIdValues = EnumValues({
    "CEDI MEDELLIN: Órdenes de Entrega": PickingTypeId.CEDI_MEDELLIN_RDENES_DE_ENTREGA,
    "PAISAPAN: Órdenes de Entrega": PickingTypeId.PAISAPAN_RDENES_DE_ENTREGA,
    "SAN SEBASTIAN: Órdenes de Entrega": PickingTypeId.SAN_SEBASTIAN_RDENES_DE_ENTREGA
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
