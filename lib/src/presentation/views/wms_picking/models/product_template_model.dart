
class Products{

  final int? id;
  final String? name;
  final dynamic listPrice;
  final dynamic barcode;
  final dynamic brandName;

  Products({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.barcode,
    required this.brandName,
     
  });

  factory Products.fromJson(Map<String, dynamic> json){
    return Products(
      id: json['id'],
      name: json['name'].toString(),
      listPrice: json['list_price'],
      barcode: json['barcode'],
      brandName: json['brand_name'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'list_price': listPrice,
      'barcode': barcode,
      'brand_name': brandName,
    };
  }


  factory Products.fromMap(Map<String, dynamic> map){
    return Products(
      id: map['id'],
      name: map['name'].toString(),
      listPrice: map['list_price'],
      barcode: map['barcode'],
      brandName: map['brand_name'],
    );
  }

  

}