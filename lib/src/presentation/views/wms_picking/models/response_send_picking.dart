import 'dart:convert';

class SendPickingResponse {
  final Data? data;

  SendPickingResponse({
    this.data,
  });

  factory SendPickingResponse.fromJson(String str) =>
      SendPickingResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SendPickingResponse.fromMap(Map<String, dynamic> json) =>
      SendPickingResponse(
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
      };
}

class Data {
  final int? code;
  final List<Result> result;

  Data({
    this.code,
    required this.result,
  });

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        code: json["code"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class Result {
  final String? complete;
  final int? idBatch;
  final int? idProduct;
  final int? idMove;

  Result({
    this.complete,
    this.idBatch,
    this.idProduct,
    this.idMove,
  });

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        complete: json["complete"],
        idBatch: json["id_batch"],
        idProduct: json["id_product"],
        idMove: json["id_move"],
      );

  Map<String, dynamic> toMap() => {
        "complete": complete,
        "id_batch": idBatch,
        "id_product": idProduct,
        "id_move": idMove,
      };
}
