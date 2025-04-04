class SendProductInventario {
  final int locationId;
  final int productId;
  final int lotId;
  final int quantity;

  SendProductInventario({
    required this.locationId,
    required this.productId,
    required this.lotId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "location_id": locationId,
      "product_id": productId,
      "lot_id": lotId,
      "quantity": quantity,
    };
  }
}
