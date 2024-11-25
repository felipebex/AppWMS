class RecentUrl{

  final int? id;
   String url;
   String fecha;

  RecentUrl({
    this.id,
    required this.url,
    required this.fecha,  
  });

  factory RecentUrl.fromJson(Map<String, dynamic> json) => RecentUrl(
    id: json["id"],
    url: json["url"],
    fecha: json["fecha"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "fecha": fecha,
  };

  


}