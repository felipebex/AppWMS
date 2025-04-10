class SendProductInventario {
  final int locationId;
  final int productId;
  final int lotId;
  final int quantity;
  final int? userId;

  SendProductInventario({
    required this.locationId,
    required this.productId,
    required this.lotId,
    required this.quantity,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      "location_id": locationId,
      "product_id": productId,
      "lot_id": lotId,
      "quantity": quantity,
      "user_id": userId,
    };
  }
}
