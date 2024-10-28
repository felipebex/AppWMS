// ignore_for_file: equal_keys_in_map

class ProductsBatch {
  final int? idProduct;
  final dynamic batchId;
  final dynamic productId;
  final dynamic pickingId;
  final dynamic lotId;
  final dynamic locationId;
  final dynamic locationDestId;
  late dynamic quantity;
  final int? quantitySeparate;
  final dynamic isSelected;
  final int? isSeparate;
  final String? timeSeparate;
  final String? timeSeparateStart;
  final String? observation;

  //variables para el picking
  late dynamic
      isLocationIsOk; //variable para si la ubicacion es leida correctamente
  late dynamic
      productIsOk; //variable para si el producto es leido correctamente
  late dynamic
      locationDestIsOk; // variable para si la ubicacion destino esta leido

  late dynamic isQuantityIsOk; //variable para si la cantidad es leida correctamente

  ProductsBatch({
    this.idProduct,
    this.batchId,
    this.productId,
    this.pickingId,
    this.lotId,
    this.locationId,
    this.locationDestId,
    this.quantity,
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

  factory ProductsBatch.fromJson(Map<String, dynamic> json) {
    return ProductsBatch(
      idProduct: json['id_product'],
      batchId: json['batch_id'],
      productId: json['product_id'],
      pickingId: json['picking_id'],
      lotId: json['lot_id'] is List ? json['lot_id'][1] : null,
      locationId: json['location_id'],
      locationDestId: json['location_dest_id'],
      quantity: json['quantity'],
      quantitySeparate: json['quantity_separate'],
      isSelected: json['is_selected'],
      isSeparate: json['is_separate'],
      timeSeparate: json['time_separate'],
      timeSeparateStart: json['time_separate_start'],
      observation: json['observation'],
      isLocationIsOk: json['is_location_is_ok'],
      productIsOk: json['product_is_ok'],
      locationDestIsOk: json['location_dest_is_ok'],
      isQuantityIsOk: json['is_quantity_is_ok'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_product': idProduct,
      'batch_id': batchId,
      'product_id': productId,
      'picking_id': pickingId,
      'lot_id': lotId,
      'location_id': locationId,
      'location_dest_id': locationDestId,
      'quantity': quantity,
      'quantity_separate': quantitySeparate,
      'is_selected': isSelected,
      'is_separate': isSeparate,
      'time_separate': timeSeparate,
      'time_separate_start': timeSeparateStart,
      'observation': observation,
      'is_location_is_ok': isLocationIsOk,
      'product_is_ok': productIsOk,
      'location_dest_is_ok': locationDestIsOk,
      'is_quantity_is_ok': isQuantityIsOk,
    };
  }

  factory ProductsBatch.fromMap(Map<String, dynamic> map) {
    return ProductsBatch(
      idProduct: map['id_product'],
      batchId: map['batch_id'],
      productId: map['product_id'],
      pickingId: map['picking_id'],
      lotId: map['lot_id'] is String ? map['lot_id'] : null,
      locationId: map['location_id'],
      locationDestId: map['location_dest_id'],
      quantity: map['quantity'],
      quantitySeparate: map['quantity_separate'],
      isSelected: map['is_selected'],
      isSeparate: map['is_separate'],
      timeSeparate: map['time_separate'],
      timeSeparateStart: map['time_separate_start'],
      observation: map['observation'],
      isLocationIsOk: map['is_location_is_ok'],
      productIsOk: map['product_is_ok'],
      locationDestIsOk: map['location_dest_is_ok'],
      isQuantityIsOk: map['is_quantity_is_ok'],
    );
  }
}
