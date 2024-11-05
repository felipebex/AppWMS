import 'dart:convert';

class BatchModelResponse {
  final Data? data;

  BatchModelResponse({
    this.data,
  });

  factory BatchModelResponse.fromJson(String str) =>
      BatchModelResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatchModelResponse.fromMap(Map<String, dynamic> json) =>
      BatchModelResponse(
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
      };
}

class Data {
  final int? code;
  final List<BatchsModel>? result;

  Data({
    this.code,
    this.result,
  });

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        code: json["code"],
        result: json["result"] == null
            ? []
            : List<BatchsModel>.from(
                json["result"]!.map((x) => BatchsModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class BatchsModel {
  final int? id;
  final String? name;
  final DateTime? scheduleddate;
  final String? pickingTypeId;
  final String? muelle; // es el mismo location_id
  final String? state;
  final dynamic userId;
  final int? countItems;

  final int? indexList;
  final dynamic? isWave;
  final int? isSeparate;
  final dynamic isSelected;
  final int? productSeparateQty; //cantidad que se lleva separada

  final double? timeSeparateTotal;
  final String? timeSeparateStart;
  final String? timeSeparateEnd;

  final String? isSendOdoo;
  final String? isSendOdooDate;
  final String? observation;

  final List<ProductsBatch>? listItems;

  BatchsModel({
    this.id,
    this.name,
    this.scheduleddate,
    this.pickingTypeId,
    this.muelle,
    this.state,
    this.userId,
    this.countItems,
    this.indexList,
    this.isWave,
    this.isSeparate,
    this.isSelected,
    this.productSeparateQty,
    this.timeSeparateTotal,
    this.timeSeparateStart,
    this.timeSeparateEnd,
    this.isSendOdoo,
    this.isSendOdooDate,
    this.observation,
    this.listItems,
  });

  factory BatchsModel.fromJson(String str) =>
      BatchsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatchsModel.fromMap(Map<String, dynamic> json) => BatchsModel(
        id: json['id'],
        name: json['name'].toString(),
        scheduleddate: json["scheduleddate"] == null
            ? null
            : DateTime.parse(json["scheduleddate"]),
        pickingTypeId: json['picking_type_id'],
        muelle: json['muelle'],
        state: json['state'],
        userId: json['user_id'],
        countItems: json['count_items'],
        indexList: json['index_list'],
        isWave: json['is_wave'],
        isSeparate: json['is_separate'],
        isSelected: json['is_selected'],
        productSeparateQty: json['product_separate_qty'],
        timeSeparateTotal: json['time_separate_total'],
        timeSeparateStart: json['time_separate_start'],
        timeSeparateEnd: json['time_separate_end'],
        isSendOdoo: json['is_send_oddo'],
        isSendOdooDate: json['is_send_oddo_date'],
        observation: json['observation'],
        listItems: json["list_items"] == null
            ? []
            : List<ProductsBatch>.from(
                json["list_items"]!.map((x) => ProductsBatch.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'scheduleddate': scheduleddate?.toIso8601String(),
        'picking_type_id': pickingTypeId,
        'muelle': muelle,
        'state': state,
        'user_id': userId,
        'count_items': countItems,
        'index_list': indexList,
        'is_wave': isWave,
        'is_separate': isSeparate,
        'is_selected': isSelected,
        'product_separate_qty': productSeparateQty,
        'time_separate_total': timeSeparateTotal,
        'time_separate_start': timeSeparateStart,
        'time_separate_end': timeSeparateEnd,
        'is_send_oddo': isSendOdoo,
        'is_send_oddo_date': isSendOdooDate,
        'observation': observation,
        'list_items': listItems == null
            ? []
            : List<dynamic>.from(listItems!.map((x) => x.toMap())),
      };
}

class ProductsBatch {
  final int? id;
  final String? barcode;
  final String? barcodes;
  final String? weigth;
  final String? unidades;

  final int? idProduct;
  final dynamic productId;
  final int? batchId;
  final String? name;
  final dynamic pickingId;
  final dynamic lotId;
  final int? loteId;
  final dynamic locationId;
  final dynamic locationDestId;
  final dynamic quantity; // Cambiado a double

  final int? quantitySeparate;
  final dynamic isSelected;
  final int? isSeparate;
  final String? timeSeparate;
  final String? timeSeparateStart;
  final String? observation;

  // Variables para el picking
  late dynamic
      isLocationIsOk; // Variable para si la ubicación es leída correctamente
  late dynamic
      productIsOk; // Variable para si el producto es leído correctamente
  late dynamic
      locationDestIsOk; // Variable para si la ubicación destino está leída
  late dynamic
      isQuantityIsOk; // Variable para si la cantidad es leída correctamente

  ProductsBatch({
    this.id,
    this.batchId,
    this.pickingId,
    this.idProduct,
    this.productId,
    this.lotId,
    this.loteId,
    this.locationId,
    this.locationDestId,
    this.quantity,
    this.barcode,
    this.name,
    this.barcodes,
    this.weigth,
    this.unidades,
    this.quantitySeparate,
    this.isSelected,
    this.isSeparate,
    this.timeSeparate,
    this.timeSeparateStart,
    this.observation,
    this.isLocationIsOk,
    this.productIsOk,
    this.locationDestIsOk,
    this.isQuantityIsOk,
  });

  // factory ProductsBatch.fromMap(Map<String, dynamic> json) {
  //   return ProductsBatch(
  //     batchId: json["batch_id"],
  //     pickingId: json["picking_id"],
  //     productId: json["product_id"],
  //     lotId: json["lot_id"],
  //     locationId: json["location_id"],
  //     locationDestId: json["location_dest_id"],
  //     quantity: json["quantity"]?.toDouble(), // Asegúrate de convertir a double
  //     barcode: json["barcode"],
  //     name: json["name"],
  //     barcodes: json["barcodes"],
  //     weigth: json["weigth"],
  //     unidades: json["unidades"],
  //     quantitySeparate: json["quantity_separate"],
  //     isSelected: json["is_selected"],
  //     isSeparate: json["is_separate"],
  //     timeSeparate: json["time_separate"],
  //     timeSeparateStart: json["time_separate_start"],
  //     observation: json["observation"],
  //     isLocationIsOk: json["is_location_is_ok"] ?? false,
  //     productIsOk: json["product_is_ok"] ?? false,
  //     locationDestIsOk: json["location_dest_is_ok"] ?? false,
  //     isQuantityIsOk: json["is_quantity_is_ok"] ?? false,
  //   );
  // }
  factory ProductsBatch.fromMap(Map<String, dynamic> map) {
    return ProductsBatch(
      id: map['id'],
      batchId: map['batch_id'],
      idProduct: map['id_product'],
      productId: map['product_id'],
      pickingId: map['picking_id'],
      lotId: map['lot_id'],
      loteId: map['lote_id'],
      
      locationId: map['location_id'],
      locationDestId: map['location_dest_id'],
      quantity: map['quantity'],
      barcode: map['barcode'],
      name: map['name'],
      barcodes: map['barcodes'],
      weigth: map['weigth'],
      unidades: map['unidades'],
      quantitySeparate: map['quantity_separate'],
      isSelected: map['is_selected'],
      isSeparate: map['is_separate'],
      timeSeparate: map['time_separate'],
      timeSeparateStart: map['time_separate_start'],
      observation: map['observation'],
      isLocationIsOk: map["is_location_is_ok"] ?? false,
      productIsOk: map["product_is_ok"] ?? false,
      locationDestIsOk: map["location_dest_is_ok"] ?? false,
      isQuantityIsOk: map["is_quantity_is_ok"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "id_product": idProduct,
      "batch_id": batchId,
      "picking_id": pickingId,
      "product_id": productId,
      "lot_id": lotId,
      "lote_id": loteId,
      "location_id": locationId,
      "location_dest_id": locationDestId,
      "quantity": quantity,
      "barcode": barcode,
      "name": name,
      "barcodes": barcodes,
      "weigth": weigth,
      "unidades": unidades,
      "quantity_separate": quantitySeparate,
      "is_selected": isSelected,
      "is_separate": isSeparate,
      "time_separate": timeSeparate,
      "time_separate_start": timeSeparateStart,
      "observation": observation,
      "is_location_is_ok": isLocationIsOk,
      "product_is_ok": productIsOk,
      "location_dest_is_ok": locationDestIsOk,
      "is_quantity_is_ok": isQuantityIsOk,
    };
  }
}
