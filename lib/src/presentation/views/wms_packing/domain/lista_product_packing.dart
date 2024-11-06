import 'dart:convert';

class PorductoPedido {
  final int? productId;
  final int? batchId;
  final int? pedidoId;
  final String? idProduct;
  final int? loteId;
  final dynamic lotId;
  final String? locationId;
  final String? locationDestId;
  final dynamic quantity;
  final String? tracking;
  final dynamic barcode;
  final dynamic weight;
  final String? unidades;
  final String? observation;
  final int? isPacking;

  //vairbales para el packing
   final int? quantitySeparate;
  final dynamic isSelected;
  final dynamic isSeparate;
  final dynamic
      isLocationIsOk; // Variable para si la ubicación es leída correctamente
  final dynamic
      productIsOk; // Variable para si el producto es leído correctamente
  final dynamic
      locationDestIsOk; // Variable para si la ubicación destino está leída
  final dynamic isQuantityIsOk; // V

  PorductoPedido({
    this.productId,
    this.batchId,
    this.pedidoId,
    this.idProduct,
    this.loteId,
    this.lotId,
    this.locationId,
    this.locationDestId,
    this.quantity,
    this.tracking,
    this.barcode,
    this.weight,
    this.unidades,
    this.quantitySeparate,
    this.isSelected,
    this.isSeparate,
    this.isPacking,
    this.isLocationIsOk,
    this.productIsOk,
    this.locationDestIsOk,
    this.isQuantityIsOk,
    this.observation,
  });

  factory PorductoPedido.fromJson(String str) =>
      PorductoPedido.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PorductoPedido.fromMap(Map<String, dynamic> json) => PorductoPedido(
        productId: json["product_id"],
        batchId: json["batch_id"],
        pedidoId: json["pedido_id"],
        idProduct: json["id_product"],
        loteId: json["lote_id"],
        lotId: json["lot_id"],
        locationId: json["location_id"],
        locationDestId: json["location_dest_id"],
        quantity: json["quantity"],
        tracking: json["tracking"],
        barcode: json["barcode"],
        weight: json["weight"],
        unidades: json["unidades"],
        quantitySeparate: json["quantity_separate"],
        isSelected: json["is_selected"],
        isSeparate: json["is_separate"],
        isLocationIsOk: json["is_location_is_ok"] ?? false,
        productIsOk: json["product_is_ok"] ?? false,
        locationDestIsOk: json["location_dest_is_ok"] ?? false,
        isQuantityIsOk: json["is_quantity_is_ok"] ?? false,
        observation: json["observation"],
        isPacking: json["is_packing"],
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "batch_id": batchId,
        "pedido_id": pedidoId,
        "id_product": idProduct,
        "lote_id": loteId,
        "lot_id": lotId,
        "location_id": locationId,
        "location_dest_id": locationDestId,
        "quantity": quantity,
        "tracking": tracking,
        "barcode": barcode,
        "weight": weight,
        "unidades": unidades,
        "quantity_separate": quantitySeparate,
        "is_selected": isSelected,
        "is_separate": isSeparate,
        "is_location_is_ok": isLocationIsOk,
        "product_is_ok": productIsOk,
        "location_dest_is_ok": locationDestIsOk,
        "is_quantity_is_ok": isQuantityIsOk,
        "observation": observation,
        "is_packing": isPacking,
      };
}
