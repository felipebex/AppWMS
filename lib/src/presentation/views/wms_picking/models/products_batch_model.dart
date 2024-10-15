class ProductsBatch {
  final dynamic productId;
  final dynamic pickingId;
  final dynamic lotId;
  final dynamic locationId;
  final dynamic locationDestId;
  late dynamic quantity;
  late dynamic isSelected; // Nuevo campo

  ProductsBatch({
    this.productId,
    this.pickingId,
    this.lotId,
    this.locationId,
    this.locationDestId,
    this.quantity,
    this.isSelected = 'false', // Asegúrate de manejarlo aquí
  });

  factory ProductsBatch.fromJson(Map<String, dynamic> json) {
    return ProductsBatch(
      productId: json['product_id'],
      pickingId: json['picking_id'],
      lotId: json['lot_id'] is List ? json['lot_id'][1] : null,
      locationId: json['location_id'],
      locationDestId: json['location_dest_id'],
      quantity: json['quantity'],
      isSelected: json['isSelected']?.toString() ?? "false",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'picking_id': pickingId,
      'lot_id': lotId,
      'location_id': locationId,
      'location_dest_id': locationDestId,
      'quantity': quantity,
      'isSelected': isSelected, // Asegúrate de manejarlo aquí
    };
  }

  factory ProductsBatch.fromMap(Map<String, dynamic> map) {
    return ProductsBatch(
      productId: map['product_id'],
      pickingId: map['picking_id'],
      lotId: map['lot_id'] is String ? map['lot_id'] : null,
      locationId: map['location_id'],
      locationDestId: map['location_dest_id'],
      quantity: map['quantity'],
      isSelected: map['isSelected']?.toString() ??
          "false", // Asegúrate de manejarlo aquí
    );
  }

  bool get isSelectedBool => isSelected == "true";
}
