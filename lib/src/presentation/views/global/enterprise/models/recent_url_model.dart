class RecentUrl{


   String url;
   String fecha;
   String method;

  RecentUrl({
    required this.url,
    required this.fecha,  
    required this.method,
  });

  factory RecentUrl.fromJson(Map<String, dynamic> json) => RecentUrl(
    url: json["url"],
    fecha: json["fecha"],
    method: json["method"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "fecha": fecha,
    "method": method,
  };

  


}