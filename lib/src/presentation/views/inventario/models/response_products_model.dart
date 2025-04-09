// To parse this JSON data, do
//
//     final getProductsInventario = getProductsInventarioFromMap(jsonString);

import 'dart:convert';

GetProductsInventario getProductsInventarioFromMap(String str) =>
    GetProductsInventario.fromMap(json.decode(str));

String getProductsInventarioToMap(GetProductsInventario data) =>
    json.encode(data.toMap());

class GetProductsInventario {
  String? jsonrpc;
  dynamic id;
  Result? result;

  GetProductsInventario({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory GetProductsInventario.fromMap(Map<String, dynamic> json) =>
      GetProductsInventario(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : Result.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class Result {
  String? status;
  List<Product>? data;

  Result({
    this.status,
    this.data,
  });

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<Product>.from(json["data"]!.map((x) => Product.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class Product {
  int? quantId;
  int? locationId;
  String? locationName;
  int? productId;
  String? productName;
  dynamic? barcode;
  String? productTracking;
  List<BarcodeInventario>? otherBarcodes;
  List<BarcodeInventario>? productPacking;
  dynamic lotId;
  dynamic lotName;
  dynamic? inDate;
  dynamic expirationDate;
  dynamic availableQuantity;
  dynamic quantity;

  Product({
    this.quantId,
    this.locationId,
    this.locationName,
    this.productId,
    this.productTracking,
    this.productName,
    this.barcode,
    this.otherBarcodes,
    this.productPacking,
    this.lotId,
    this.lotName,
    this.inDate,
    this.expirationDate,
    this.availableQuantity,
    this.quantity,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        quantId: json["quant_id"],
        locationId: json["location_id"],
        locationName: json["location_name"],
        productId: json["product_id"],
        productName: json["product_name"],
        barcode: json["barcode"],
        otherBarcodes: json["other_barcodes"] == null
            ? []
            : List<BarcodeInventario>.from(json["other_barcodes"]!
                .map((x) => BarcodeInventario.fromMap(x))),
        productPacking: json["product_packing"] == null
            ? []
            : List<BarcodeInventario>.from(json["product_packing"]!
                .map((x) => BarcodeInventario.fromMap(x))),
        lotId: json["lot_id"],
        lotName: json["lot_name"],
        inDate: json["in_date"],
        expirationDate: json["expiration_date"],
        availableQuantity: json["available_quantity"],
        quantity: json["quantity"],
        productTracking: json["product_tracking"],
      );

  Map<String, dynamic> toMap() => {
        "quant_id": quantId,
        "location_id": locationId,
        "location_name": locationName,
        "product_id": productId,
        "product_name": productName,
        "barcode": barcode,
        "other_barcodes": otherBarcodes == null
            ? []
            : List<dynamic>.from(otherBarcodes!.map((x) => x.toMap())),
        "product_packing": productPacking == null
            ? []
            : List<dynamic>.from(productPacking!.map((x) => x)),
        "lot_id": lotId,
        "lot_name": lotName,
        "in_date": inDate,
        "expiration_date": expirationDate,
        "available_quantity": availableQuantity,
        "quantity": quantity,
        "product_tracking": productTracking,
      };
}

class BarcodeInventario {
  dynamic barcode;
  dynamic idProduct;
  dynamic idQuant;
  dynamic cantidad;

  BarcodeInventario({
    this.barcode,
    this.idProduct,
    this.idQuant,
    this.cantidad,
  });

  factory BarcodeInventario.fromMap(Map<String, dynamic> json) =>
      BarcodeInventario(
          barcode: json["barcode"],
          idQuant: json["quant_id"],
          idProduct: json["id_product"],
          cantidad: json["cantidad"]);

  Map<String, dynamic> toMap() => {
        "barcode": barcode,
        "quant_id": idQuant,
        "id_product": idProduct,
        "cantidad": cantidad,
      };
}
