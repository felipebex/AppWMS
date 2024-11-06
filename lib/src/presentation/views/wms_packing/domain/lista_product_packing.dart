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
    });

    factory PorductoPedido.fromJson(String str) => PorductoPedido.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory PorductoPedido.fromMap(Map<String, dynamic> json) => PorductoPedido(
        productId: json["product_id"],
        batchId: json["batch_id"],
        pedidoId: json["pedido_id"],
        idProduct: json["id_product"] ,
        loteId: json["lote_id"],
        lotId: json["lot_id"],
        locationId: json["location_id"] ,
        locationDestId: json["location_dest_id"],
        quantity: json["quantity"],
        tracking: json["tracking"],
        barcode: json["barcode"],
        weight: json["weight"],
        unidades: json["unidades"] 
    );

    Map<String, dynamic> toMap() => {
        "product_id": productId,
        "batch_id": batchId,
        "pedido_id": pedidoId,
        "id_product": idProduct,
        "lote_id": loteId,
        "lot_id": lotId,
        "location_id": locationId ,
        "location_dest_id": locationDestId ,
        "quantity": quantity,
        "tracking": tracking,
        "barcode": barcode,
        "weight": weight,
        "unidades": unidades
    };
}
