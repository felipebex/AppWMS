class ProductPacking {
  final dynamic productId;
  final dynamic lotName;
  final dynamic expirationDate;
  final dynamic locationDestId;
  final dynamic resultPackageId;
  final dynamic quantity;
  final dynamic productUomId;


  ProductPacking({
    required this.productId,
    required this.lotName,
    required this.expirationDate,
    required this.locationDestId,
    required this.resultPackageId,
    required this.quantity,
    required this.productUomId,
  });


  factory ProductPacking.fromJson(Map<String, dynamic> json) {
    return ProductPacking(
      productId: json['product_id'],
      lotName: json['lot_name'],
      expirationDate: json['expiration_date'],
      locationDestId: json['location_dest_id'],
      resultPackageId: json['result_package_id'],
      quantity: json['quantity'],
      productUomId: json['product_uom_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'lot_name': lotName,
      'expiration_date': expirationDate,
      'location_dest_id': locationDestId,
      'result_package_id': resultPackageId,
      'quantity': quantity,
      'product_uom_id': productUomId,
    };
  }


  factory ProductPacking.fromMap(Map<String, dynamic> map) {
    return ProductPacking(
      productId: map['product_id'],
      lotName: map['lot_name'],
      expirationDate: map['expiration_date'],
      locationDestId: map['location_dest_id'],
      resultPackageId: map['result_package_id'],
      quantity: map['quantity'],
      productUomId: map['product_uom_id'],
    );
  }


  

















}