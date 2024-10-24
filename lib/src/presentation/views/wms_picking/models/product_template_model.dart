class Products {
  final int? id;
  final String? name;
  final String? barcode;
  final String? tracking;

  Products({
     this.id,
     this.name,
     this.barcode,
    this.tracking,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      name: json['name'].toString(),
      barcode:
          json['barcode'] is bool && !json['barcode'] ? "" : json['barcode'],
   
      tracking: json['tracking'] is bool && !json['tracking']
          ? ""
          : json['tracking'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'tracking': tracking,
    };
  }

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
      id: map['id'],
      name: map['name'].toString(),
      barcode: map['barcode'] is bool && !map['barcode'] ? "" : map['barcode'],
      tracking: map['tracking'] is bool && !map['tracking'] ? "" : map['tracking'],
    );
  }
}
